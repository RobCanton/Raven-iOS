//
//  AlertViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2019-08-19.
//  Copyright © 2019 Robert Canton. All rights reserved.
//

import Foundation
import UIKit



class AlertViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let editingMode:Bool
    let stock:PolygonStock
    
    var alert:AlertEditable
    
    var tableView:UITableView!
    var tableViewBottomAnchor:NSLayoutConstraint!
    var saveButton:UIButton!
    var rightBarButtonItem:UIBarButtonItem!

    
    init(stock:PolygonStock, alert:Alert?=nil) {
        self.editingMode = alert != nil
        self.stock = stock
        if alert != nil {
            self.alert = alert!.editable
        } else {
            self.alert = AlertEditable(id: "",
                                       type: .price,
                                       condtion: PriceCondition.isOver.rawValue,
                                       value: nil,
                                       reset: 2,
                                       enabled: 1)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = editingMode ? "Edit Alert" : "New Alert"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .secondarySystemGroupedBackground
        appearance.shadowImage = UIImage()
        
        
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.label
        
        view.backgroundColor = UIColor.systemBackground
        
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        //tableView.backgroundColor = UIColor.systemBackground
        view.addSubview(tableView)
        tableView.constraintToSuperview(0, 0, nil, 0, ignoreSafeArea: false)
        tableViewBottomAnchor = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        tableViewBottomAnchor.isActive = true
        tableView.keyboardDismissMode = .interactive
        tableView.register(SegmentedControlCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tempCell")
        tableView.register(AlertTextFieldCell.self, forCellReuseIdentifier: "textCell")
        tableView.register(AlertSwitchCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(DeleteCell.self, forCellReuseIdentifier: "deleteCell")
        tableView.register(ResetCell.self, forCellReuseIdentifier: "resetCell")
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44 + 32, right: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:
            UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        tableViewBottomAnchor.constant = -keyboardSize.height
        view.layoutIfNeeded()
        
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        tableViewBottomAnchor.constant = 0
        view.layoutIfNeeded()
    }
    
    @objc func handleSave() {
        
        
        guard alert.isValid else {
            print("Unable to save alert: invalid")
            return
        }
        
        print("Save Alert: \(alert)")
        
        if editingMode {
            PolyravenAPI.patchAlert(alert) { alert in
                if alert != nil {
                    StockManager.shared.updateAlert(alert!)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            PolyravenAPI.createAlert(alert, for: stock) { alert in
                if alert != nil {
                    StockManager.shared.addAlert(alert!)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
   
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       switch section {
       case 0:
            return 3
       case 1:
            return 3
       case 2:
        return 1
       case 3:
            return editingMode ? 1 : 0
       default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Conditions"
        case 1:
            return "Actions"
        case 2:
            return nil
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            return "In-app notifications will always be sent."
        case 2:
            return "Determines how long before this alert resets and can be triggered again."
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SegmentedControlCell
                
                cell.segmentedControl.removeAllSegments()
                
                
                var selectedIndex = 0
                for i in 0..<AlertType.all.count {
                    let alertType = AlertType.all[i]
                    if alertType == alert.type {
                        selectedIndex = i
                    }
                    cell.segmentedControl.insertSegment(withTitle: alertType.title, at: i, animated: false)
                }
                
                cell.segmentedControl.selectedSegmentIndex = selectedIndex
                cell.indexPath = indexPath
                cell.delegate = self
                
                return cell
            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SegmentedControlCell
                    
                cell.segmentedControl.removeAllSegments()
                    
                var selectedIndex = 0
                for i in 0..<PriceCondition.all.count {
                    let condition = PriceCondition.all[i]
                    if condition.rawValue == alert.condtion {
                        selectedIndex = i
                    }
                    cell.segmentedControl.insertSegment(withTitle: condition.stringValue, at: i, animated: false)
                }
                
                cell.segmentedControl.selectedSegmentIndex = selectedIndex
                cell.indexPath = indexPath
                cell.delegate = self
                return cell
                
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! AlertTextFieldCell
                
                switch alert.type {
                case .price:
                    cell.label.text = "Price"
                    if let value = alert.value {
                        cell.textField.text = "\(value)"
                    } else {
                        cell.textField.text = nil
                    }
                    cell.textField.placeholder = "\(stock.lastTrade?.price ?? 0.00)"
                    cell.indexPath = indexPath
                    cell.delegate = self

                    break
                default:
                    break
                }
                
                return cell
            default:
                break
            }
            break
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! AlertSwitchCell
                cell.textLabel?.text = "Send Push Notification"
                cell.switchView.setOn(true, animated: false)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! AlertSwitchCell
                cell.textLabel?.text = "Send Email"
                cell.detailTextLabel?.text = "robshanecanton@gmail, replicodechannel@gmail.com"
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! AlertSwitchCell
                cell.textLabel?.text = "Send Text Message"
                return cell
            default:
                break
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "resetCell", for: indexPath)
            let resetDelay = ResetDelay(rawValue: alert.reset)!
            cell.textLabel?.text = "Reset"
            cell.detailTextLabel?.text = resetDelay.name
            cell.detailTextLabel?.textColor = UIColor.secondaryLabel
            return cell
            /*let cell = tableView.dequeueReusableCell(withIdentifier: "tempCell", for: indexPath)
            let resetDelay = ResetDelay.all[indexPath.row]
            cell.textLabel?.text = resetDelay.name
            let isSelected = resetDelay.rawValue == alert.reset
            if isSelected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell*/
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell", for: indexPath)
            return cell
        default:
            break
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let textCell = tableView.cellForRow(at: indexPath) as? AlertTextFieldCell
        textCell?.textField.isUserInteractionEnabled = true
        textCell?.textField.becomeFirstResponder()
        
        if cell.isKind(of: DeleteCell.self) {
            let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                StockManager.shared.deleteAlert(withID: self.alert.id) {
                    self.dismiss(animated: true, completion: nil)
                }
            }))
            
            alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertSheet, animated: true, completion: nil)
        } else if cell.isKind(of: ResetCell.self) {
            let vc = ResetSelectViewController(selectedOption: alert.reset)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

extension AlertViewController: SegmentedControlCellDelegate {
    func segmentedControlCell(indexPath: IndexPath, didSelect index: Int) {
        switch indexPath.row {
        case 0:
            alert.type = AlertType(rawValue: Int16(index))!
            let reloadRows = [
                IndexPath(row: 1, section: 0),
                IndexPath(row: 2, section: 0)
            ]
            tableView.reloadRows(at: reloadRows, with: .automatic)
            break
        case 1:
            switch alert.type {
            case .price:
                
                alert.condtion = index + 1
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
}

extension AlertViewController: AlertTextFieldCellDelegate {
    func alertTextFieldCell(indexPath: IndexPath, didTextChange text: String?) {
        let value = text != nil ? Double(text!) : nil
        switch indexPath.row {

        case 2:
            switch alert.type {
            case .price:
                alert.value = value
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
}

extension AlertViewController:ResetSelectDelegate {
    func resetSelect(didSelect option: ResetDelay) {
        alert.reset = option.rawValue
        self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
    }
}
