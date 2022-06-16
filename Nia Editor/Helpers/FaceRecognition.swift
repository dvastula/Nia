//
//  FaceRecognition.swift
//  Nia Editor
//
//  Created by Damir Minnegalimov on 21.05.2021.
//

import AVFoundation
import Vision

class FaceRecognizer {
  // Vision requests
  private var detectionRequests: [VNDetectFaceRectanglesRequest]?
  private var trackingRequests: [VNTrackObjectRequest]?
  lazy var sequenceRequestHandler = VNSequenceRequestHandler()
  let faceLandmarksDetectionRequest = createFaceRequest()

  func processVideo(asset: AVAsset) async {
    let reader = try! AVAssetReader(asset: asset)

    let videoTrack = try! await asset.loadTracks(withMediaType: .video).first!

    // read video frames as BGRA
    let outputSettings = [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)]
    let readerOutput = AVAssetReaderTrackOutput(
      track: videoTrack,
      outputSettings:outputSettings)

    reader.add(readerOutput)
    reader.startReading()

    prepareVisionRequest()

    while reader.status == .reading,
          let sampleBuffer = readerOutput.copyNextSampleBuffer() {
      // print("sample at time \(CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds)")

      if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
        // process each CVPixelBufferRef here
        // CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))

        self.handle(pixelBuffer: imageBuffer) {
          // CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }
      }
    }
  }

  // MARK: Performing Vision Requests
  fileprivate func prepareVisionRequest() {

    //self.trackingRequests = []
    var requests = [VNTrackObjectRequest]()

    let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
      if error != nil {
        print("FaceDetection error: \(String(describing: error)).")
      }

      guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
            let results = faceDetectionRequest.results else {
        return
      }

      //      DispatchQueue.main.async {
      // Add the observations to the tracking list
      for observation in results {
        let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
        requests.append(faceTrackingRequest)
      }
      self.trackingRequests = requests
      //      }
    })

    // Start with detection.  Find face, then track it.
    self.detectionRequests = [faceDetectionRequest]
    self.sequenceRequestHandler = VNSequenceRequestHandler()
  }

  fileprivate func handle(
    pixelBuffer: CVImageBuffer,
    completion: @escaping () -> Void
  ) {
    guard let requests = self.trackingRequests, !requests.isEmpty else {
      // No tracking object detected, so perform initial detection
      let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)

      do {
        guard let detectRequests = self.detectionRequests else {
          completion()
          return
        }

        try imageRequestHandler.perform(detectRequests)
      } catch let error as NSError {
        NSLog("Failed to perform FaceRectangleRequest: %@", error)
      }

      completion()
      return
    }

    do {
      try self.sequenceRequestHandler.perform(
        requests,
        on: pixelBuffer)
    } catch let error as NSError {
      NSLog("Failed to perform SequenceRequest: %@", error)
    }

    // Setup the next round of tracking.
    var newTrackingRequests = [VNTrackObjectRequest]()

    for trackingRequest in requests {
      guard let results = trackingRequest.results else {
        completion()
        return
      }

      guard let observation = results[0] as? VNDetectedObjectObservation else {
        completion()
        return
      }

      if !trackingRequest.isLastFrame {
        if observation.confidence > 0.3 {
          trackingRequest.inputObservation = observation
        } else {
          trackingRequest.isLastFrame = true
        }

        newTrackingRequests.append(trackingRequest)
      }
    }

    self.trackingRequests = newTrackingRequests

    if newTrackingRequests.isEmpty {
      // Nothing to track, so abort.
      completion()
      return
    }

    // Perform face landmark tracking on detected faces.
    var faceLandmarkRequests = [VNDetectFaceLandmarksRequest]()

    // Perform landmark detection on tracked faces.
    for trackingRequest in newTrackingRequests {

      let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request, error) in

        if error != nil {
          print("FaceLandmarks error: \(String(describing: error)).")
        }

        guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
              let results = landmarksRequest.results else {
          completion()
          return
        }

        print(results.count)
        // Perform all UI updates (drawing) on the main queue, not the background queue on which this handler is being called.
        //        DispatchQueue.main.async {
        //          self.drawFaceObservations(results)
        //        }
      })

      guard let trackingResults = trackingRequest.results else {
        completion()
        return
      }

      guard let observation = trackingResults[0] as? VNDetectedObjectObservation else {
        completion()
        return
      }

      let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
      faceLandmarksRequest.inputFaceObservations = [faceObservation]

      // Continue to track detected facial landmarks.
      faceLandmarkRequests.append(faceLandmarksRequest)

      let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)

      do {
        try imageRequestHandler.perform(faceLandmarkRequests)
      } catch let error as NSError {
        NSLog("Failed to perform FaceLandmarkRequest: %@", error)
      }
    }

    completion()
    return
  }
}

extension FaceRecognizer {
  public func process(image: CGImage) -> [VNFaceObservation] {
    let requestOptions:[VNImageOption : Any] = [:]
    let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: requestOptions)
    let faceLandmarksDetectionRequest = VNDetectFaceLandmarksRequest()
    faceLandmarksDetectionRequest.revision = 2

    try! imageRequestHandler.perform([faceLandmarksDetectionRequest])

    guard let faceLandmarks = faceLandmarksDetectionRequest.results else {
      fatalError("unexpected result type from VNCoreMLRequest")
    }

    return faceLandmarks;
  }

  public func process(pixelBuffer: CVImageBuffer) -> [VNFaceObservation] {
    let handler = VNImageRequestHandler(
      cvPixelBuffer: pixelBuffer,
      options: [:])

    do {
      try handler.perform([faceLandmarksDetectionRequest])
    } catch {
      print(error)
    }

    guard let faceLandmarks = faceLandmarksDetectionRequest.results else {
      print("unexpected result type from VNCoreMLRequest")
      return []
    }

    return faceLandmarks
  }
}

func createFaceRequest() -> VNDetectFaceLandmarksRequest {
  let faceLandmarksDetectionRequest = VNDetectFaceLandmarksRequest()
  faceLandmarksDetectionRequest.revision = 2

//  faceLandmarksDetectionRequest.completionHandler = VNRequestCompletionHandler

  return faceLandmarksDetectionRequest
}
