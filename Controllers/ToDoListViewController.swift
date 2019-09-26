//
//  ViewController.swift
//  Todoey
//
//  Created by Matthew Braden on 2019-07-11.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        // Occurs as soon as selectedCategory gets a value
        didSet {
            loadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        loadData()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let colorHex = selectedCategory?.color else {fatalError("COLOR DNE")}
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //    MARK - Navbar Setup Method
    func updateNavBar(withHexCode colorHexCode : String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("NAV DNE")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError("NAV COLOR DNE")}
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    //    MARK - Tableview Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(todoItems!.count))) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            //        New Way of if else statements
            cell.accessoryType = item.done == true ? .checkmark : .none
        }
        else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }

    //    MARK - Tableview Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }
            catch {
                print("Error reversing done relationship \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //    MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch {
                    print("Error Saving Data \(error)")
                }
            }
            self.tableView.reloadData()
        }

        alert.addAction(action)
        alert.addTextField {
            (alertTextField) in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }

    //    Mark - Model Manipulation Methods
    
    func loadData() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let todoItemDeletion = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(todoItemDeletion)
                }
            }
            catch {
                print("Error deleting data \(error)")
            }
        }
    }
}

//    Mark - Search Bar Delegate Methods

extension ToDoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
//            Allows Stuff To Go On In Background
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
}
