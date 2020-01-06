//
//  ViewController.swift
//  Todoey
//
//  Created by Jimmy Martini on 2/6/19.
//  Copyright © 2019 Jimmy Martini. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet{ // everything in these curly braces will execute when the variable gets set/initialized
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAtIndexPath called")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //Ternary operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        // FOR DELETING FROM CORE DATA
        // itemArray.remove(at: indexPath.row) // remove locally
        // context.delete(itemArray[indexPath.row]) // remove from permanent storage (Core Data)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen when the user clicks the add item button on our UIAlert
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK - Model Manipuation Methods
    
    func saveItems() {
        
        do {
            try context.save() // Always need to call this when creating, updating, or deleting data from Core Data for changes to persist.
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData() // forces the tableView to call it's DataSource method again so that it reloads data that's meant to be inside
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) { // This notation means that if we don't pass in the param when we call this function, the system will auto initialize a new param to use inside.
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
    }
    
}

// Extensions give you the ability to split up certain functionality of your view controller to keep actions related to certain events organized.
// Below, we are extending our view controller class for the purposes of adding search bar methods since we added a search bar.
// This helps keeps view controller files from getting too crammed with a bunch of methods for different things. Another advantage of this is making debugging issues easier since we are isolating code depending on the event it relates to.
// IF I EVER USE SEARCH BARS IN MY APPS, LOOKS UP THE NSPREDICATE CHEATSHEET FROM REALM TO LEARN HOW TO STRUCTURE SEARCH QUERIES FOR MY DATA.

//MARK: - Search Bar Methods
extension ToDoListViewController : UISearchBarDelegate {
    
    // This method gets fired off when we press enter after typing in text in the Search bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) // NSPredicate is a foundation class that specifies how data should be fetched/filtered. It's a query language.
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] // sorts the results we get back
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async { // runs an asynchronous process in the foreground on a different thread so this method doesn't slow down your app -- USEFUL!
                searchBar.resignFirstResponder() // This just means to no longer be the thing that is currently selected. Once the search bar text clears, reload all of the persisted data, and deselect the search bar.
            }
        }
    }
}
