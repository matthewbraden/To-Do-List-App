//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Matthew Braden on 2019-07-17.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    //    Mark - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        Nil Coellesing Property
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
//        ?? is for when categoryArray is nil
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name ?? "No Categories Added Yet"
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError("COLOR DNE")}
            
            cell.backgroundColor = UIColor(hexString: category.color ?? "1D9BF6")
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        return cell
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) {
            (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.saveData(category: newCategory)
        }
        
        alert.addAction(action)
        alert.addTextField {
            (field) in
            textField = field
            textField.placeholder = "create new category"
            
        }
        present(alert, animated: true, completion: nil)
    }
    
    //    Mark - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //    Mark - DataManipulation Methods
    func saveData(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("Error when saving data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryDeletion = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryDeletion)
                }
            }
            catch {
                print("Error deleting data \(error)")
            }
        }
    }
}
