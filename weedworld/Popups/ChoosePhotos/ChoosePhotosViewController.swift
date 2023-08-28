//
//  ChoosePhotosViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 31/1/2023.
//

import UIKit
import PhotosUI


protocol ChooseOptionDelegate: AnyObject {
    func passData(_ image: UIImage, _ previousImage: UIImage, _ text: String)
}

class ChoosePhotosViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    @IBOutlet weak var gradienView: UIView!
    @IBOutlet weak var textTF: UITextField!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var pickBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    weak var delegate: ChooseOptionDelegate?
    let images = ["camera.fill", "photo.fill", "textformat.size"]
    var previousImage: UIImage?
    var selectedItem = 1
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        textTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setGradien()
    }
    
    func setupUI() {
        buttonsCollectionView.register(UINib(nibName: "ChooseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "chooseCell")
        pickBtn.layer.cornerRadius = pickBtn.frame.height / 2
        textTF.attributedPlaceholder = NSAttributedString(string: "Type something here..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        previousImage = backgroundImage.image
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text != "" {
            submitBtn.isEnabled = true
        }
        else {
            submitBtn.isEnabled = backgroundImage.image != previousImage
        }
    }
    
    func setGradien() {
        let colorTop = UIColor.darkGray.cgColor
        let colorBottom = UIColor.clear.cgColor
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = gradienView.bounds
        
        gradienView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func pickBtnClick(_ sender: UIButton) {
        selectedItem == 0 ? showUserCamera() : showImagePicker()
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        guard let image = backgroundImage.image, let text = textTF.text, let prevIm = previousImage else { return }
        dismiss(animated: true)
        delegate?.passData(image, prevIm, text)
    }
    
    @IBAction func backClick(_ sender: UIButton) {
        dismiss(animated: true)
    }
}


extension ChoosePhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chooseCell", for: indexPath) as! ChooseCollectionViewCell
        
        cell.logoImage.image = UIImage(systemName: images[indexPath.item])
        
        if selectedItem == indexPath.item {
            cell.contentImage.alpha = 1
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                cell.transform = cell.transform.scaledBy(x: 1.3, y: 1.3)
              })
        }
        else {
            cell.contentImage.alpha = 0.5
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = indexPath.item
        textTF.isHidden = selectedItem != 2
        pickBtn.isHidden = selectedItem == 2
        pickBtn.setTitle(selectedItem == 0 ? "Pick from camera" : "Pick from gallery", for: .normal)
        pickBtn.setImage(selectedItem == 0 ? UIImage(systemName: "camera.fill") : UIImage(systemName: "photo.fill"), for: .normal)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = collectionView.frame.height * 3
        let totalSpacingWidth = CGFloat(15 * (images.count - 1))

        let leftInset = max(0.0, (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2)

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: leftInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

// MARK: Library
extension ChoosePhotosViewController: PHPickerViewControllerDelegate {
    
    func showImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let `self` = self, let image = image as? UIImage else { return }
                    self.backgroundImage.image = image
                    self.submitBtn.isEnabled = true
                }
            })
        }
    }
}

// MARK: Camera
extension ChoosePhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showUserCamera() {
        // Check if the device has a camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Device has a camera, now create the image picker controller
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true)
        }
        else {
            print("no camera")
        }
    }
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(.originalImage)] as? UIImage {
            picker.dismiss(animated: true)
            self.backgroundImage.image = pickedImage
            self.submitBtn.isEnabled = true
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}
