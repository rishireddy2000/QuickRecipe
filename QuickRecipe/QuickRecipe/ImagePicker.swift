import Foundation
import SwiftUI

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    

    @Binding var image: UIImage?
    @Binding var isShown: Bool

    init(image: Binding<UIImage?>, isShown: Binding<Bool>) {
        _image = image
        _isShown = isShown
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("Image picked: \(uiImage)")
            image = uiImage
            isShown = false
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker cancelled by user")
        isShown = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator

    @Binding var image: UIImage?
    @Binding var isShown: Bool

    var sourceType: UIImagePickerController.SourceType = .camera

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // This method intentionally left blank.
    }

    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePickerCoordinator(image: $image, isShown: $isShown)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        print("Opening UIImagePickerController with sourceType: \(sourceType.rawValue)")
        picker.delegate = context.coordinator
        return picker
    }
}


