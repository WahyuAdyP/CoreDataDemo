//
//  DetailViewController.swift
//  CoreDataDemo
//
//  Created by Crocodic-MBP5 on 06/07/20.
//  Copyright © 2020 Crocodic Studio. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = user.nama
        
        label.numberOfLines = 0
        label.text = """
        \(user.id) - \(user.nama)
        In address: \(user.address)
        With coordinates:
        \(user.coordinates?.coordinates.map({ "* \($0.latitude), \($0.longitude)" }).joined(separator: "\n") ?? "No coordinates")
        """
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
