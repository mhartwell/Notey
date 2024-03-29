//
//  ViewController.swift
//  Notey
//
//  Created by Michael Hartwell on 7/4/19.
//  Copyright © 2019 Mike Hartwell. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    //array of Category entities
    var categories = [Category]()
    //declare our context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("\(paths)...")
        
        loadCategories()
    }
    //MARK: - Table functions go here
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    //returns the user selected cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categories[indexPath.row]
        print("Category cell loaded for...\(category.title!)")
        //print("Category cell loaded...")
        cell.textLabel?.text = category.title
        
        return cell
    }
    //performs the segue to the notebooks view when the user selects a category
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected a Category cell...")
        self.performSegue(withIdentifier: "goToNotebooks", sender: self)
    }
    
    //MARK:- Segue function here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! NotebookViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationViewController.selectedCategory = categories[indexPath.row]
        }else{
            print("Error performing segue...")
        }
    }
    //MARK:- Button Pressed Method
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            print("Creating new Category object...")
            let newCategory = Category(context: self.context)
            newCategory.title = textField.text
            
            self.categories.append(newCategory)
            self.saveCategories()
        }
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        print("Presenting new Category alert...")
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Data Manipulation Functions
    //saves the user created categories to coredata
    func saveCategories(){
        do{
            try context.save()
            print("saving category...")
        }catch{
            print("error saving to coreData \(error)...")
        }
        self.tableView.reloadData()
    }
    //Loads Categories the user has created
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest(), predicate: NSPredicate? = nil){
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        let categoryPredicate = NSPredicate(format: "title != nil")
        if let additionalPredicate = predicate{
            print("Loading searched Categories...")
            request.predicate = additionalPredicate
        }else{
            print("Loading default Categories...")
            request.predicate = categoryPredicate
        }
        do{
            categories = try context.fetch(request)
            print("Loading Categories...")
        }catch{
            print("Error fetching request \(error)...")
        }
        print("Reloading Category data...")
        tableView.reloadData()
    }
    
    
}
//MARK:- Extensions
extension CategoryViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //TODO: - add searching logic
        print("Search button clicked...")
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true )]
        
        print("Searching Categories for '\(searchBar.text!)'...")
        
        loadCategories(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("User is typing in SearchBar...")
        if searchBar.text?.count == 0 {
            print("User cleared Category search box...")
            //load default data set
            loadCategories()
            DispatchQueue.main.async {
                //close the keyboard and remove cursor
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
