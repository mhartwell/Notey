//
//  NotebookViewController.swift
//  Notey
//
//  Created by Michael Hartwell on 7/5/19.
//  Copyright © 2019 Mike Hartwell. All rights reserved.
//

import UIKit
import CoreData

class NotebookViewController: UITableViewController{
    
    var notebooks = [Notebook]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: Category?{
        didSet{
            loadNotebooks()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    //MARK: TableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebooks.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        //TODO: perform segue to the notebook editing
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notebookCell", for: indexPath)
        let notebook = notebooks[indexPath.row]

        cell.textLabel?.text = notebook.name!

        return cell
    }
    //MARK: - Data Manipulation methods
    func loadNotebooks(with request: NSFetchRequest<Notebook> = Notebook.fetchRequest(), predicate: NSPredicate? = nil){
        //establish new predicatre
        let notebookPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", selectedCategory!.title!)
        //if parameter request is supplied, use that. if not, use default
        if let additionalPredicate = predicate{
            request.predicate = additionalPredicate
        }else{
            request.predicate = notebookPredicate
        }
        do{
            notebooks = try context.fetch(request)
        }catch{
            print("Error fetching notebooks \(error)...")
        }
    }
    
    func saveNotebooks(){
        do{
            print("Saving Notebook...")
            try context.save()
            
        }catch{
            print("error saving notebook \(error)...")
        }
        tableView.reloadData()
    }
    //MARK:- Add Notebook methods
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new Notebook", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Notebook", style: .default) { (action) in
            let newNotebook = Notebook(context: self.context)
            newNotebook.name = textField.text
            newNotebook.parentCategory = self.selectedCategory
            self.notebooks.append(newNotebook)
            self.saveNotebooks()
        }
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
