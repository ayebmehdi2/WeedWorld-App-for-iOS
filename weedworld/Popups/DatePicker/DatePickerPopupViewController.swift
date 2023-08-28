//
//  DatePickerPopupViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 15/1/2023.
//

import UIKit

protocol DatePickerPopupDelegate: AnyObject {
    func getSelectedDate(date: String)
    func viewDismissed()
}

class DatePickerPopupViewController: UIViewController {

    @IBOutlet weak var datePickerHeaderView: UIView!
    @IBOutlet weak var datePickerStackView: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate: DatePickerPopupDelegate?
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
    }
    
    func setupDatePicker() {
        datePickerHeaderView.layer.cornerRadius = 15
        datePickerHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.backgroundColor = .systemBackground
        datePicker.maximumDate = Date()
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        dismiss(animated: true)
        delegate?.viewDismissed()
    }
    
    @IBAction func doneClick(_ sender: UIButton) {
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en")
        let date = formatter.string(from: datePicker.date)
        delegate?.getSelectedDate(date: date)
        delegate?.viewDismissed()
        dismiss(animated: true)
    }
    
    @IBAction func grayViewClick(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
        delegate?.viewDismissed()
    }
}
