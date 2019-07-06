//
//  NotebookViewController.swift
//  Notey
//
//  Created by Michael Hartwell on 7/5/19.
//  Copyright © 2019 Mike Hartwell. All rights reserved.
//

import UIKit
import CoreData

class NotebookViewController: UITableViewController {
    
    
    var selectedCategory: Category?{
        didSet{
            //loadNotebooks()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }

    

}
