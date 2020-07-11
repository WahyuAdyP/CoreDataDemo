//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Crocodic-MBP5 on 02/07/20.
//  Copyright © 2020 Crocodic Studio. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var addBtn: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(refreshControl)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        
        addBtn.target = self
        addBtn.action = #selector(addUser)
        
        reloadData()
    }
    
    @objc func reloadData() {
        refreshControl.endRefreshing()
        users = DatabaseHelper.shared.getAllData(objectType: User.self)
        tableView.reloadData()
    }

    @objc func addUser() {
        inputUser()
    }
    
    @objc func inputUser(user: User? = nil) {
        let alert = UIAlertController(title: "Input User", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.text = user?.nama
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Address"
            textField.text = user?.address
        }
        let save = UIAlertAction(title: "Save", style: .default) { (action) in
            let name = alert.textFields?[0].text
            let address = alert.textFields?[1].text
            
            let newUser = user != nil ? user! : User()
            newUser.nama = name ?? ""
            newUser.address = address ?? ""
            let coordinates = Coordinates()
            for i in 0 ..< 5 {
                let coordinate = Coordinate(latitude: Double(i * newUser.id), longitude: Double(i * newUser.id))
                coordinates.coordinates.append(coordinate)
            }
            newUser.coordinates = coordinates
            _ = DatabaseHelper.shared.addData(object: newUser)
            
            self.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(save)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "ID: \(users[indexPath.row].id) - " + (users[indexPath.row].nama)
        cell.detailTextLabel?.text = users[indexPath.row].address
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.user = users[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let data = self.users[indexPath.row]
            self.users.remove(at: indexPath.row)
            _ = DatabaseHelper.shared.deleteData(object: data)
            
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        deleteAction.backgroundColor = .red
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let data = self.users[indexPath.row]
            self.inputUser(user: data)
        }
        editAction.backgroundColor = .green
        return [deleteAction, editAction]
    }
}
