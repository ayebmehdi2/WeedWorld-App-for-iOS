//
//  CheckoutViewController.swift
//  weedworld
//
//  Created by Mac on 8/7/2023.
//

import UIKit
import FirebaseAuth

class CheckoutViewController: UIViewController {
    
    var store: LocalStore?
    var products: [Product] = []
    var subTotal: Double = 0
    var orderTotal: Double = 0
    var deliveryMethod = 1
    var addressHeightConstraint = NSLayoutConstraint()
    var feeHeightConstraint = NSLayoutConstraint()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollViewBG: UIScrollView!
    @IBOutlet weak var itemsStack: UIStackView!
    @IBOutlet weak var deliveryFeeView: UIStackView!
    @IBOutlet weak var deliveryFee: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var salesTaxLabel: UILabel!
    @IBOutlet weak var stateTaxLabel: UILabel!
    @IBOutlet weak var orderTotalLabel: UILabel!
    @IBOutlet weak var pickupButton: UIButton!
    @IBOutlet weak var deliveryButton: UIButton!
    
    
    @IBOutlet weak var deliveryStack: UIStackView!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lasNameLabel: UITextField!
    @IBOutlet weak var mobileLabel: UITextField!
    @IBOutlet weak var deliveryTextView: UITextView! {
        didSet {
            deliveryTextView.layer.cornerRadius = 20
            deliveryTextView.layer.borderWidth = 1
            deliveryTextView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBOutlet weak var checkoutButton: UIButton! {
        didSet {
            checkoutButton.layer.cornerRadius = 22.5
            checkoutButton.backgroundColor = UIColor(red: 0.99, green: 0.56, blue: 0.11, alpha: 1)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addressHeightConstraint = self.deliveryStack.heightAnchor.constraint(equalToConstant: 140)
        feeHeightConstraint = self.deliveryFeeView.heightAnchor.constraint(equalToConstant: 30)
        addressHeightConstraint.isActive = true
        feeHeightConstraint.isActive = true
        setupNavBar()
        setupRadioButtons()
        createItemsStack()
        populateOrder(delFee: store?.deliveryFee ?? 0)
    }
    
    func setupNavBar() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.89, blue: 0.78, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: store?.businessName, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }
    
    func setupRadioButtons() {
        pickupButton.setImage(UIImage(named: "unchecked"), for: .normal)
        pickupButton.setImage(UIImage(named: "checked"), for: .selected)
        deliveryButton.setImage(UIImage(named: "unchecked"), for: .normal)
        deliveryButton.setImage(UIImage(named: "checked"), for: .selected)
    }
    
    func createItemsStack() {
        for product in products {
            let price = (product.price ?? 0) * Double(product.quantity ?? 1)
            subTotal += price
            let productTitle = UILabel()
            productTitle.text = product.name
            productTitle.font = UIFont(name: "Poppins-Medium", size: 14)
            let productPrice = UILabel()
            productPrice.text = "\(price)$"
            productPrice.font = UIFont(name: "Poppins-Medium", size: 14)
            productPrice.textAlignment = .right
            let stackView = UIStackView(arrangedSubviews: [productTitle, productPrice])
            stackView.distribution = .fillProportionally
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            itemsStack.addArrangedSubview(stackView)
        }
    }
    
    func populateOrder(delFee: Double) {
        let salesFee: Double = store?.salesTax ?? 0
        let stateFee: Double = store?.stateTax ?? 0
        DispatchQueue.main.async {
            
            self.deliveryFeeView.translatesAutoresizingMaskIntoConstraints = false
            self.deliveryStack.translatesAutoresizingMaskIntoConstraints = false
            if delFee == -1 {
                self.feeHeightConstraint.constant = 0
                self.addressHeightConstraint.constant = 0
            }else {
                self.deliveryFee.text = "\(delFee)$"
                self.feeHeightConstraint.constant = 30
                self.addressHeightConstraint.constant = 140
            }
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        salesTaxLabel.text = "\(salesFee)$"
        stateTaxLabel.text = "\(stateFee)$"
        let subTotalValue = subTotal + (delFee == -1 ? 0 : delFee)
        subTotalLabel.text = "\(subTotalValue)$"
        orderTotal = subTotalValue + salesFee + stateFee
        orderTotalLabel.text = "\(orderTotal)$"
    }
    
    @IBAction func chooseDeliveryState(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        sender.isSelected = !sender.isSelected
        switch sender {
        case pickupButton:
            deliveryMethod = 0
            deliveryButton.isSelected = false
            populateOrder(delFee: -1)
            deliveryStack.isHidden = true
        default:
            deliveryMethod = 1
            pickupButton.isSelected = false
            populateOrder(delFee: store?.deliveryFee ?? 0)
            deliveryStack.isHidden = false
        }
        self.view.layoutIfNeeded()
    }
    
    @IBAction func confirmOrder(_ sender: Any) {
        if let firstName = firstNameLabel.text, let lastName = lasNameLabel.text, let mobile = mobileLabel.text, let deliveryAddress = deliveryTextView.text, let store = store {
            if firstName.isEmpty || lastName.isEmpty || mobile.isEmpty || (deliveryAddress.isEmpty && deliveryMethod == 1) {
                let alert = UIAlertController(title: "Fail", message: "All fields must be filled!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                present(alert, animated: true)
            }else {
                showActivityIndicator(view: view, activityIndicator: activityIndicator)
                let image = self.generateQRCode(from: "firstName: \(firstName), lastName: \(lastName), phone number: \(mobile), address: \((deliveryAddress.isEmpty ? "Pickup" : deliveryAddress))")
                
                let productIds = products.map({ product in
                    return product.productId
                })
                
                let order = Order(storeId: store.storeId, storeName: store.businessName, products: productIds, userId: Auth.auth().currentUser!.uid, orderTotal: String(orderTotal), firstName: firstName, lastName: lastName, mobileNumber: mobile, deliveryMode: deliveryMethod, deliverAddress: (deliveryAddress.isEmpty ? nil : deliveryAddress), timestamp: nil, qrCode: image?.pngData()?.base64EncodedString())
                
                order.saveOrder(completion: { success in
                    if success {
                        let confirm = ConfirmationViewController()
                        confirm.image = image
                        confirm.store = store
                        self.navigationController?.pushViewController(confirm, animated: true)
                    }
                    else {
                        self.showAlert(title: "Error", message: "An error has occured.")
                    }
                    self.stopActivityIndicator(activityIndicator: self.activityIndicator)
                })
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}
