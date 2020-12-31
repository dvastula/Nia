//
//  ImagePicker.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 09.11.2020.
//

import UIKit
import SwiftUI
import MobileCoreServices
import AVKit

struct ImagePicker: UIViewControllerRepresentable {
  
  @Environment(\.presentationMode) var presentationMode
  //  @Binding var image: UIImage?
  let onLoad: (Any?) -> ()
  
  class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

      let mediaType: CFString = info[.mediaType] as! CFString
      
      if mediaType == kUTTypeImage,
         let originalUIImage = info[.originalImage] as? UIImage {
        
        parent.onLoad(originalUIImage)
      } else if mediaType == kUTTypeMovie || mediaType == kUTTypeVideo,
                let mediaURL = (info[.mediaURL] as? NSURL)?.absoluteURL
      {
        let avAsset = AVAsset(url: mediaURL)
        
        parent.onLoad(avAsset)
      } else {
        print("WTF is this: \(info)")
      }
      
      parent.presentationMode.wrappedValue.dismiss()
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator

    picker.mediaTypes = [
      kUTTypeImage as String,
      kUTTypeVideo as String,
      kUTTypeMovie as String
    ]
        
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController,
                              context: UIViewControllerRepresentableContext<ImagePicker>) {
    
  }
}
