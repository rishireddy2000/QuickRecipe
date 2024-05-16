//
//  ImagePicker.swift
//  MixnMatch
//
//  Created by Prudhvi Puli on 05/03/24.
//

import Foundation
import SwiftUI

// Initializes the coordinator with bindings for the selected image and the picker's visibility.

//class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//    
//    @Binding var image: UIImage? // The selected image, bound to be used outside this coordinator.
//    @Binding var isShown: Bool // Controls the visibility of the UIImagePickerController, bound to be used outside.
//    
//    /// Initializes the coordinator with bindings for the selected image and the picker's visibility.
//    init(image: Binding<UIImage?>, isShown: Binding<Bool>) {
//        _image = image
//        _isShown = isShown
//    }
//    
//    /// Called when the user picks an image. Updates the bound image and hides the picker.
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        
//        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            print("Image picked: \(uiImage)") // Log the image picked for debugging.
//            image = uiImage
//            isShown = false
//        }
//    }
//    
//    /// Called when the user cancels the picker. Just hides the picker without updating the image.
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("Image picker cancelled by user") // Log cancellation for debugging.
//        isShown = false
//    }
//    
//}
//
///// `ImagePicker` is a SwiftUI wrapper for UIImagePickerController, allowing image selection in a SwiftUI view.
//struct ImagePicker: UIViewControllerRepresentable {
//    
//    typealias UIViewControllerType = UIImagePickerController
//    typealias Coordinator = ImagePickerCoordinator
//    
//    @Binding var image: UIImage? // The selected image, to be used in the SwiftUI view.
//    @Binding var isShown: Bool // Controls the visibility of the UIImagePickerController in the SwiftUI view.
//    
//    var sourceType: UIImagePickerController.SourceType = .camera // Defines the source of the image picker (camera, photo library, etc.)
//    
//    /// Updates the UIImagePickerController. Currently, this method does nothing but is required by the protocol.
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
//        // This method intentionally left blank.
//    }
//    
//    /// Creates the coordinator that handles UIImagePickerControllerDelegate methods.
//    func makeCoordinator() -> ImagePicker.Coordinator {
//        return ImagePickerCoordinator(image: $image, isShown: $isShown)
//    }
//    
//    /// Creates the UIImagePickerController and configures it with a source type and delegate.
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
//        
//        let picker = UIImagePickerController()
//        picker.sourceType = sourceType
//        print("Opening UIImagePickerController with sourceType: \(sourceType.rawValue)") // Log the source type for debugging.
//        picker.delegate = context.coordinator
//        return picker
//    }
//}

// This class manages interactions with the UIImagePickerController, such as image selection and cancellation.
class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    

    @Binding var image: UIImage? // Represents the selected image, bound for external use.
    @Binding var isShown: Bool // Controls the visibility of the UIImagePickerController, bound for external use.

    /// Initializes the coordinator with bindings for the selected image and the picker's visibility.
    /// - Parameters:
    ///   - image: The selected image binding.
    ///   - isShown: The visibility binding for the image picker.
    init(image: Binding<UIImage?>, isShown: Binding<Bool>) {
        _image = image
        _isShown = isShown
    }

    /// Called when the user picks an image. Updates the bound image and hides the picker.
    /// - Parameters:
    ///   - picker: The UIImagePickerController instance.
    ///   - info: The info dictionary containing details about the picked media.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Log the selected image for debugging
            print("Image picked: \(uiImage)")
            image = uiImage
            isShown = false
        }
    }

    /// Called when the user cancels the picker. Just hides the picker without updating the image.
    /// - Parameter picker: The UIImagePickerController instance.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker cancelled by user") // Log cancellation for debugging.
        isShown = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    // A SwiftUI wrapper for UIImagePickerController, enabling image selection in a SwiftUI view.

    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator

    @Binding var image: UIImage? // Represents the selected image, to be used in the SwiftUI view.
    @Binding var isShown: Bool // Controls the visibility of the UIImagePickerController in the SwiftUI view.

    var sourceType: UIImagePickerController.SourceType = .camera // Defines the source of the image picker (camera, photo library, etc.)

    /// Updates the UIImagePickerController. Currently, this method does nothing but is required by the protocol.
    /// - Parameters:
    ///   - uiViewController: The UIImagePickerController instance to be updated.
    ///   - context: The context for the view controller representation.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // This method intentionally left blank.
    }

    /// Creates the coordinator that handles UIImagePickerControllerDelegate methods.
    /// - Returns: An instance of ImagePickerCoordinator.
    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePickerCoordinator(image: $image, isShown: $isShown)
    }

    /// Creates the UIImagePickerController and configures it with a source type and delegate.
    /// - Parameter context: The context for the view controller representation.
    /// - Returns: An instance of UIImagePickerController configured for image picking.
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        // Log the source type for debugging
        print("Opening UIImagePickerController with sourceType: \(sourceType.rawValue)")
        picker.delegate = context.coordinator
        return picker
    }
}


