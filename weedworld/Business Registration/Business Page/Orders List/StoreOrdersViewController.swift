//
//  StoreOrdersViewController.swift
//  weedworld
//
//  Created by Mac on 22/7/2023.
//

import UIKit

class StoreOrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyOrdersView: UIView!
    var ordersArray: [Order] = []
    var store: LocalStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Orders"
        setupNavBar()
        let orderCell = UINib(nibName: "StoreOrderCell", bundle: nil)
        tableView.register(orderCell, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        Task {
            async let orders = getOrders()
            ordersArray = await orders
            DispatchQueue.main.async {
                if self.ordersArray.isEmpty {
                    self.tableView.isHidden = true
                }else {
                    self.tableView.isHidden = false
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func setupNavBar() {
//        view.backgroundColor = UIColor(red: 0.95, green: 0.89, blue: 0.78, alpha: 1)
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: store?.businessName, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }
    
    @objc func backBtnClick() {
        dismiss(animated: true)
    }
    
    func getOrders() async -> [Order] {
        guard let storeId = store?.storeId else { return [] }
        let orders = try? await FirebaseHelper.getOrdersByStoreId(storeId: storeId)
        guard let orders = orders else {
            showAlert(title: "Error", message: "An error has occured please try later.")
            return []
        }
        tableView.reloadData()
        return orders
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreOrderCell
        let order = ordersArray[indexPath.row]
        if let orderId = order.orderId, let qrCode = order.qrCode, let status = order.deliveryStatus {
            cell.orderIDLabel.text = "\(orderId)"
            if status == 0 {
                cell.orderStatusLAbel.text = "Order Status: Pending"
                cell.orderStatusLAbel.textColor = .orange
                cell.validateButton.isHidden = false
            }else {
                cell.orderStatusLAbel.text = "Order Status: Delivered"
                cell.orderStatusLAbel.textColor = .green
                cell.validateButton.isHidden = true
            }
            let imageData = Data(base64Encoded: qrCode)
            let image = UIImage(data: imageData!)
            cell.qrImage.image = image
            cell.validateButton.tag = indexPath.row
            cell.validateButton.addTarget(self, action: #selector(validate(sender:)), for: .touchUpInside)
        }
        return cell
    }
    
    @objc func validate(sender: UIButton){
        Task {
            async let result = updateOrder(index: sender.tag)
            let status = await result
            if status {
                showAlert(title: "Alert", message: "Success")
                Task {
                    async let orders = getOrders()
                    ordersArray = await orders
                    DispatchQueue.main.async {
                        if self.ordersArray.isEmpty {
                            self.tableView.isHidden = true
                        }else {
                            self.tableView.isHidden = false
                        }
                        self.tableView.reloadData()
                    }
                }
            }else {
                showAlert(title: "Alert", message: "Error")
            }
            stopActivityIndicator(activityIndicator: activityIndicator)
        }
    }
    
    func updateOrder(index: Int) async -> Bool {
        if let orderId = ordersArray[index].orderId {
            showActivityIndicator(view: view, activityIndicator: activityIndicator)
            var order = ordersArray[index]
            order.deliveryStatus = 1
            let resultUpdate = try! await FirebaseHelper.updateOrder(orderId: orderId, order: order)
            
            return resultUpdate
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
