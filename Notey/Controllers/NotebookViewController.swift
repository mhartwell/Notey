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
        
        //establish which notebook to dequeue
        let cell = tableView.dequeueReusableCell(withIdentifier: "notebookCell", for: indexPath)
        //let the system know what notebook we want
        let notebook = notebooks[indexPath.row]
        print("Notebook cell loaded for...\(notebook.name!)")
        cell.textLabel?.text = notebook.name!

        return cell
    }
    //MARK: - Data Manipulation methods
    func loadNotebooks(with request: NSFetchRequest<Notebook> = Notebook.fetchRequest(), predicate: NSPredicate? = nil){
        var logTxt : String = ""
        //establish new predicatre
        let notebookPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", selectedCategory!.title!)
        //if parameter request is supplied, use that. if not, use default
        if let additionalPredicate = predicate{
            logTxt = "Fetching user requested Notebook..."
            request.predicate = additionalPredicate
        }else{
            logTxt = "Fetching all Notebooks..."
            request.predicate = notebookPredicate
        }
        do{
            print("\(logTxt)")
            //fetch the request
            notebooks = try context.fetch(request)
        }catch{
            //report error if it doesn't work
            print("Error fetching notebooks \(error)...")
        }
        tableView.reloadData()
    }
    
    func saveNotebooks(){
        do{
            //save notebook to the database
            print("Saving Notebook...")
            try context.save()
            
        }catch{
            //report error back if failed to save
            print("error saving notebook \(error)...")
        }
        //reload our new data
        tableView.reloadData()
    }
    //MARK:- Add Notebook methods
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        //set up alert
        let alert = UIAlertController(title: "Add a new Notebook", message: "", preferredStyle: .alert)
        //set our alert action
        let action = UIAlertAction(title: "Add Notebook", style: .default) { (action) in
            print("Creating new Notebook object...")
            //set up our Notebook object for the added notebook
            let newNotebook = Notebook(context: self.context)
            newNotebook.name = textField.text
            newNotebook.parentCategory = self.selectedCategory
            //add notebook to our array of notebooks
            self.notebooks.append(newNotebook)
            //save new notebook to the database
            self.saveNotebooks()
        }
        //set up the rest of the alert
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        //add action to alert and present it to the user
        print("Presenting New Notebook Alert...")
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
extension NotebookViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button clicked...")
        let request : NSFetchRequest<Notebook> = Notebook.fetchRequest()
        
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        print("Searching Notebooks for '\(searchBar.text!)'...")
        
        loadNotebooks(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            print("User cleared Notebook search box")
            //load default dataset
            loadNotebooks()
            DispatchQueue.main.async{
                //close keyboard and remove cursor
                searchBar.resignFirstResponder()
            }
        }
        
    }
}
