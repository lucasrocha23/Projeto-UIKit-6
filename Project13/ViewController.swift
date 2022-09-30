//
//  ViewController.swift
//  Project13
//
//  Created by Lucas Rocha on 30/09/22.
//
import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet var filterOption: UIButton!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var radius: UISlider!
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Editor"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        filterOption.menu = UIMenu(children:[
            UIAction(title: "Sepia", handler: sepiaOption),
            UIAction(title: "Vignette", handler: vignetteOption),
            UIAction(title: "Vignette Effect", handler: vigEffectOption)
        ])

        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    func vigEffectOption(_ action: UIAction){
        currentFilter = CIFilter(name: "CIVignetteEffect")
        loadFilter()
    }
    
    func sepiaOption(_ action: UIAction){
        currentFilter = CIFilter(name: "CISepiaTone")
        loadFilter()
    }
    
    func vignetteOption(_ action: UIAction){
        currentFilter = CIFilter(name: "CIVignette")
        loadFilter()
    }
    
    func loadFilter(){
        guard let beginImage = CIImage(image: currentImage) else{ return }
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

    @objc func importPicture(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else{ return }
        dismiss(animated: true)
        currentImage = image
        imageView.alpha = 0.1
        UIView.animate(withDuration: 1, delay: 0, animations: {
            self.imageView.alpha = 1
        })
        
        loadFilter()
    }
    
    
    @IBAction func save(_ sender: Any) {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }else{
            let ac = UIAlertController(title: "Save error", message: "There is no image to save", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac,animated: true)
        }
    }
    
    @IBAction func intensityChange(_ sender: Any) {
        currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        applyProcessing()
    }

    @IBAction func radiusChange(_ sender: Any) {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputRadiusKey){
            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
            applyProcessing()
        }
    }
    
    func applyProcessing(){
        if let cgImage = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent){
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error{
            let ac = UIAlertController(title: "Save errror", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac,animated: true)
        }else{
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac,animated: true)
        }
    }
    
}

