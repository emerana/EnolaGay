//
//  ToastViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/8/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class ToastViewCtrl: UITableViewController {
    
    fileprivate var showingActivity = false
    
    fileprivate struct ReuseIdentifiers {
        static let switchCellId = "switchCell"
        static let exampleCellId = "exampleCell"
    }
    
    // MARK: - Constructors
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        self.title = "Toast-Swift"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifiers.exampleCellId)

    }
    
    // MARK: - Events
    
    @objc
    private func handleTapToDismissToggled() {
        ToastManager.shared.isTapToDismissEnabled = !ToastManager.shared.isTapToDismissEnabled
    }
    
    @objc
    private func handleQueueToggled() {
        ToastManager.shared.isQueueEnabled = !ToastManager.shared.isQueueEnabled
    }
}

// MARK: - UITableViewDelegate & DataSource Methods

extension ToastViewCtrl {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 11
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "SETTINGS"
        } else {
            return "EXAMPLES"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.switchCellId)
            
            if indexPath.row == 0 {
                if cell == nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: ReuseIdentifiers.switchCellId)
                    let tapToDismissSwitch = UISwitch()
                    tapToDismissSwitch.onTintColor = .red
                    tapToDismissSwitch.isOn = ToastManager.shared.isTapToDismissEnabled
                    tapToDismissSwitch.addTarget(self, action: #selector(ToastViewCtrl.handleTapToDismissToggled), for: .valueChanged)
                    cell?.accessoryView = tapToDismissSwitch
                    cell?.selectionStyle = .none
                    cell?.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
                }
                cell?.textLabel?.text = "Tap to dismiss"
            } else {
                if cell == nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: ReuseIdentifiers.switchCellId)
                    let queueSwitch = UISwitch()
                    queueSwitch.onTintColor = .red
                    queueSwitch.isOn = ToastManager.shared.isQueueEnabled
                    queueSwitch.addTarget(self, action: #selector(ToastViewCtrl.handleQueueToggled), for: .valueChanged)
                    cell?.accessoryView = queueSwitch
                    cell?.selectionStyle = .none
                    cell?.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
                }
                cell?.textLabel?.text = "Queue toast"
            }
            
            return cell!
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.exampleCellId, for: indexPath)
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.accessoryType = .disclosureIndicator

            switch indexPath.row {
            case 0: cell.textLabel?.text = "Make toast"
            case 1: cell.textLabel?.text = "Make toast on top for 3 seconds"
            case 2: cell.textLabel?.text = "Make toast with a title"
            case 3: cell.textLabel?.text = "Make toast with an image"
            case 4: cell.textLabel?.text = "Make toast with a title, image, and completion closure"
            case 5: cell.textLabel?.text = "Make toast with a custom style"
            case 6: cell.textLabel?.text = "Show a custom view as toast"
            case 7: cell.textLabel?.text = "Show an image as toast at point\n(110, 110)"
            case 8: cell.textLabel?.text = showingActivity ? "Hide toast activity" : "Show toast activity"
            case 9: cell.textLabel?.text = "Hide toast"
            case 10: cell.textLabel?.text = "Hide all toasts"
            default: cell.textLabel?.text = nil
            }
            
            return cell
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // Make Toast
            navigationController?.view.toast.makeToast("This is a piece of toast")
        case 1:
            // Make toast with a duration and position
            navigationController?.view.toast.makeToast("This is a piece of toast on top for 3 seconds", duration: 3.0, position: .top)
        case 2:
            // Make toast with a title
            navigationController?.view.toast.makeToast("This is a piece of toast with a title", duration: 2.0, position: .top, title: "Toast Title", image: nil)
        case 3:
            // Make toast with an image
            navigationController?.view.toast.makeToast("This is a piece of toast with an image", duration: 2.0, position: .center, title: nil, image: UIImage(named: "toast.png"))
        case 4:
            // Make toast with an image, title, and completion closure
            navigationController?.view.toast.makeToast("This is a piece of toast with a title, image, and completion closure", duration: 2.0, position: .bottom, title: "Toast Title", image: nil) { didTap in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }
        case 5:
            // Make toast with a custom style
            var style = ToastStyle()
            style.messageFont = UIFont(size: 13)
            style.messageColor = .red
            style.messageAlignment = .center
            style.backgroundColor = .purple
            navigationController?.view.toast.makeToast("This is a piece of toast with a custom style", duration: 3.0, position: .bottom, style: style)
        case 6:
            // Show a custom view as toast
            let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 400.0))
            customView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            customView.backgroundColor = .green
            navigationController?.view.toast.showToast(customView, duration: 2.0, position: .center)
        case 7:
            // Show an image view as toast, on center at point (110,110)
            let toastView = UIImageView(image: UIImage(named: "toast.png"))
            navigationController?.view.toast.showToast(toastView, duration: 2.0, point: CGPoint(x: 110.0, y: 110.0))
        case 8:
            // Make toast activity
            if !showingActivity {
                navigationController?.view.toast.makeToastActivity(.center)
            } else {
                navigationController?.view.toast.hideToastActivity()
            }
            
            showingActivity.toggle()
            
            tableView.reloadData()
        case 9:
            // Hide toast
            navigationController?.view.toast.hideToast()
        case 10:
            // Hide all toasts
            navigationController?.view.toast.hideAllToasts()
        default:
            break
        }
    }
}
