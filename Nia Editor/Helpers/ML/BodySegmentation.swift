//
//  BodySegmentation.swift
//  Nia Editor
//
//  Created by Damir Minnegalimov on 15.07.2022.
//

import Vision
import CoreImage.CIFilterBuiltins


final class BodySegmentation {
  // The Vision requests and the handler to perform them.
  private var segmentationRequest = VNGeneratePersonSegmentationRequest()
  
  // The Core Image pipeline.
//  let bodyFillImage = CIImage(color: CIColor(red: 1, green: 0, blue: 0, alpha: 0.5))
//  let bodyRectFillImage = CIImage(color: CIColor(red: 0, green: 1, blue: 0, alpha: 0.2))
  
  public var ciContext: CIContext!
//  public var currentCIImage: CIImage?
  
  private func intializeRequests() {
    // Create a request to segment a person from an image.
    segmentationRequest = VNGeneratePersonSegmentationRequest()
    segmentationRequest.qualityLevel = .accurate
    segmentationRequest.outputPixelFormat = kCVPixelFormatType_OneComponent32Float
  }
    
  // MARK: - Process Results
  // Performs the blend operation.
  private func blend(
    original originalCIImage: CIImage,
    mask maskCIImage: CIImage
  ) -> CGImage? {
    
    // Create CIImage objects for the video frame and the segmentation mask.
    let originalImage = originalCIImage.oriented(.up)
    
    // Scale the mask image to fit the bounds of the video frame.
    let scaleX = originalImage.extent.width / maskCIImage.extent.width
    let scaleY = originalImage.extent.height / maskCIImage.extent.height

    let maskImage = maskCIImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
    
    // Blend the original, background, and mask images.
    let blendFilter = CIFilter.blendWithMask()
//    blendFilter.backgroundImage = originalImage
//    blendFilter.inputImage = bodyFillImage.composited(over: originalImage)

    blendFilter.inputImage = originalImage
    blendFilter.maskImage = maskImage
    
    // Set the new, blended image as current.
    let resultImage = blendFilter.outputImage?.oriented(.up)
    return resultImage?.getCGImage()
  }
  
}

extension BodySegmentation {
  public func process(image: CGImage) -> CGImage? {
    let requestOptions:[VNImageOption : Any] = [:]
    let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: requestOptions)
    
    // Perform the requests on the pixel buffer that contains the video frame.
    try? imageRequestHandler.perform([segmentationRequest])
    
    guard let observations = segmentationRequest.results else {
      fatalError("unexpected result type from VNCoreMLRequest")
    }

    // Get the pixel buffer that contains the mask image.
    guard let maskPixelBuffer = observations.first?.pixelBuffer else {
      print("ERROR while Segmentation: there is no observations")
      return nil
    }
    
    let ciOriginal = CIImage(cgImage: image)
    let ciMask = CIImage(cvPixelBuffer: maskPixelBuffer)
    
    return blend(original: ciOriginal, mask: ciMask)
  }
}
