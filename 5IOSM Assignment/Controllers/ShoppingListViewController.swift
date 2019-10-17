//
//  ShoppingListViewController.swift
//  5IOSM Assignment
//
//  Created by Jefferson MARINHO GOMES (001088479) on 11/9/19.
//  Copyright © 2019 Jefferson MARINHO GOMES (001088479). All rights reserved.
//

import UIKit
import SQLite3

// Structure to handle sections in the list
struct Section {
    var name: ShopItem.ItemType // Define the name of a section as the type of the item
    var items: [ShopItem] // Store the array of items
}

class ShoppingListViewController: UITableViewController, AddItemDelegate {

    var ShoppingList:[ShopItem] = [] // Creates a shopping list array
    var sections = [Section]() // Creates an array of sections
    var db: OpaquePointer? = nil
    
    //let i1 = ShopItem(name: "Eggs", price: 3.50,quantity: 1, type: .Dairy)
//    let i2 = ShopItem(name: "Milk", price: 1.50, quantity: 4, type: .Dairy)
//    let i3 = ShopItem(name: "Flour", price: 2.99, quantity: 1, type: .Meat)
//    let i4 = ShopItem(name: "Butter", price: 2.40, quantity: 1, type: .Dairy)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard connectToDB() else {
            print("Error connecting")
            return
        }
        
        getItems()

//        ShoppingList = [i1,i2,i3,i4]
        
        // Group the items in the shopping list by type
        let groups = Dictionary(grouping: ShoppingList, by: { $0.type })
        
        // Stores the sections in the section structure
        self.sections = groups.map(Section.init(name:items:))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem // Add the Edit button to the left side of the screen
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of section
        return self.sections.count // Uses the section array to provide the number of sections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].name.rawValue // Return the name of the type
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.sections[section].items.count // Get the number of rows for each section
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let section = self.sections[indexPath.section] // First get the section
        let item = section.items[indexPath.row] // Then get item inside that section
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text =  String(item.quantity!)

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the Item from the Database
            guard connectToDB() else {
                print("Error connecting")
                return
            }
            guard deleteItem(id: self.sections[indexPath.section].items[indexPath.row].id) else {
                print("Could Not delete!")
                return
            }
            
            tableView.beginUpdates() // Start the updates
            
            // Delete the row from the data source
            self.sections[indexPath.section].items.remove(at: indexPath.row)
            // Delete the row from the tableView
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // If there is no more item in the section
            if self.sections[indexPath.section].items.count == 0 {
                // Remove the section from the array
                self.sections.remove(at: indexPath.section)
                // Remove the section from the tableView
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            }
            
            tableView.endUpdates() // Confirm the updates
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addItem" {
            let controller = segue.destination as! AddItemViewController
            controller.delegate = self
        }
    }
    
    func didSaveItem(item: ShopItem) {
        let index = self.sections.firstIndex(where: { $0.name == item.type})
        if index != nil {
            self.sections[index!].items += [item]
        } else {
            let section = Section(name: item.type, items: [item])
            self.sections += [section]
        }
        tableView.reloadData()
    }
    
    // MARK: - DATABASE
    
    func getDBPath() -> String
    {
        let devicePaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDir = devicePaths[0] // Get the first path, which is documents
        let dbPath = (documentsDir as NSString).appendingPathComponent("ShoppingList.db")
        return dbPath
    }
    
    func connectToDB() -> Bool
    {
        if sqlite3_open(getDBPath(), &db) == SQLITE_OK {
            print("Successfully connected to database!")
            return true
        } else {
            print("Connection failed!")
            return false
        }
    }
    
    func getItems()
    {
        let stmt = "SELECT * FROM List"
        var queryStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, stmt, -1, &queryStmt, nil) == SQLITE_OK {
            print("We select something")
            while sqlite3_step(queryStmt) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(queryStmt, 0))
                let name = String(cString: sqlite3_column_text(queryStmt, 1))
                let price = sqlite3_column_double(queryStmt, 2)
                let type = ShopItem.ItemType(rawValue: String(cString: sqlite3_column_text(queryStmt, 3))) ?? ShopItem.ItemType.Other
                let quantity = Int(sqlite3_column_int(queryStmt, 4))
                
                let item = ShopItem(id: id, name: name, price: price, type: type, quantity: quantity)
                
                ShoppingList.append(item)
            }
        } else {
            print("Something went wrong")
        }
        
        sqlite3_finalize(queryStmt)
        sqlite3_close(db)        
    }
    
    func deleteItem(id: Int) -> Bool
    {
        var result: Bool = false
        let stmt = "DELETE FROM List WHERE ItemKey = ?;"
        var queryStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, stmt, -1, &queryStmt, nil) == SQLITE_OK {
            //Binding values
            sqlite3_bind_int(queryStmt, 1, Int32(id))
            
            if sqlite3_step(queryStmt) == SQLITE_DONE {
                result = true
            }
        }
        
        sqlite3_finalize(queryStmt)
        sqlite3_close(db)
        return result
    }
}
