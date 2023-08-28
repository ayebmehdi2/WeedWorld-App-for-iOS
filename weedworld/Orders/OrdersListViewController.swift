//
//  OrdersListViewController.swift
//  weedworld
//
//  Created by Mac on 21/7/2023.
//

import UIKit

class OrdersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyOrdersView: UIView!
    var ordersArray: [Order] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Orders"
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.95, green: 0.89, blue: 0.78, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backBtnClick))
        let orderCell = UINib(nibName: "OrderCell", bundle: nil)
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
    
    
    @objc func backBtnClick() {
        dismiss(animated: true)
    }
    
    func getOrders() async -> [Order] {
        let orders = try? await FirebaseHelper.getUserOrders()
        guard let orders = orders else {
            showAlert(title: "Error", message: "An error has occured please try later.")
            return []
        }
        return orders
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderCell
        let order = ordersArray[indexPath.row]
        if let orderId = order.orderId, let qrCode = order.qrCode, let storeName = order.storeName, let status = order.deliveryStatus {
            cell.orderLabel.text = "Order ID: \(orderId)"
            cell.storeLabel.text = "Store: \(storeName)"
            if status == 0 {
                cell.deliveryStatus.text = "Order Status: Pending"
                cell.deliveryStatus.textColor = .orange
            }else {
                cell.deliveryStatus.text = "Order Status: Delivered"
                cell.deliveryStatus.textColor = .green
            }
            let imageData = Data(base64Encoded: qrCode)
            let image = UIImage(data: imageData!)
            cell.qrImage.image = image
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}
