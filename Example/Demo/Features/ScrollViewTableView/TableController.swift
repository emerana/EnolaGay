//
//  ViewController.swift
//  TableViewAtScrollView
//
//  Created by Judy-王仁洁 on 2017/4/25.
//  Copyright © 2017年 Judy.仁杰. All rights reserved.
//

import UIKit
import EnolaGay

class TableController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHigh: NSLayoutConstraint!

    @IBOutlet weak var userNameLB: UILabel!
    
    var cellNumbers = 8
    
    @IBAction func deleteCell(_ sender: Any) {
        if cellNumbers <= 0 {
           cellNumbers += 1
            self.tableView.insertRows(at:[IndexPath(row: 0, section: 0)] , with: UITableView.RowAnimation.fade)
        } else {
            cellNumbers -= 1
            self.tableView.deleteRows(at:[IndexPath(row: 0, section: 0)] , with: UITableView.RowAnimation.fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            self.tableViewHigh.constant = self.tableView.contentSize.height
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 6.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        tableViewHigh.constant = self.tableView.contentSize.height
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return cellNumbers
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
}
