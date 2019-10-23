//
//  DetailViewController.swift
//  5IOSM Assignment
//
//  Created by Jefferson MARINHO GOMES (001088479) on 11/9/19.
//  Copyright © 2019 Jefferson MARINHO GOMES (001088479). All rights reserved.
//

import UIKit
import SQLite3

protocol UpdateItemDelegate {
    func didUpdateItem(indexPath: IndexPath, item: ShopItem)
}


class DetailViewController: UIViewController {
    
    var item: ShopItem!
    var itemIndexPath: IndexPath!

    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var itemTypeTextField: UITextField!
    @IBOutlet weak var itemQuantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    let pickerView = UIPickerView() // Create a pickerview
    
    var delegate: UpdateItemDelegate? // Delegate to alert when item is saved
    
    var db: OpaquePointer? = nil // Database
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard connectToDB() else {
            print("Error connecting")
            return
        }
        
        pickerView.delegate = self // Set this controller as the delegate
        // Set the pickerview as the input view of the textfield
        itemTypeTextField.inputView = pickerView

        itemNameTextField.text = item.name!
        itemPriceTextField.text = String(item.price!)
        itemTypeTextField.text = item.type.rawValue
        pickerView.selectRow(ShopItem.ItemType.allCases.firstIndex(of: item.type)!, inComponent: 0, animated: false)
        itemQuantityTextField.text = String(item.quantity!)
        quantityStepper.value = Double(item.quantity!)
                
        self.navigationItem.rightBarButtonItem = self.editButtonItem // Add the Edit button to the left side of the screen
        
        setEditing(false, animated: true) // Disable editing
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        if self.isEditing && !editing {
            if SaveItem() {
                super.setEditing(editing, animated: animated)
                itemNameTextField.isEnabled = editing
                itemPriceTextField.isEnabled = editing
                itemTypeTextField.isEnabled = editing
                itemQuantityTextField.isEnabled = editing
                quantityStepper.isEnabled = editing
            }
        } else {
            super.setEditing(editing, animated: animated)            
            itemNameTextField.isEnabled = editing
            itemPriceTextField.isEnabled = editing
            itemTypeTextField.isEnabled = editing
            itemQuantityTextField.isEnabled = editing
            quantityStepper.isEnabled = editing
        }
    }

    func SaveItem() -> Bool{
        guard let name = itemNameTextField.text, !name.isEmpty else {
            self.showToast(title: "Field Required", message: "Item Name is required!")
            return false
        }
        
        guard let price = Double(itemPriceTextField.text!), !price.isNaN else {
            self.showToast(title: "Field Required", message: "Price is required!")
            return false
        }
        
        guard let quantity = Int(itemQuantityTextField.text!), quantity > 0 else {
            self.showToast(title: "Field Required", message: "Quantity is required!")
            return false
        }
        
        guard let type = itemTypeTextField.text, !type.isEmpty else {
            self.showToast(title: "Field Required", message: "Type is required!")
            return false
        }
        
        let result = updateItem(id: item.id, name: name, price: price, type: ShopItem.ItemType(rawValue: type) ?? .Other, quantity: quantity)
        
        if result != 0 {
            item.name = name
            item.price = price
            item.type = ShopItem.ItemType(rawValue: type) ?? .Other
            item.quantity = quantity
            
            self.delegate?.didUpdateItem(indexPath: self.itemIndexPath, item: item)
        }
        
        return true
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
    
    // This function will return the ID of the new Item inserted or 0 if error
    func updateItem(id: Int, name: String, price: Double, type: ShopItem.ItemType, quantity: Int) -> Int
    {
        var result: Int = 0 // Variable to return the result
        
        let stmt = "UPDATE List SET ItemName = ?, ItemPrice = ?, ItemType = ?, Quantity = ? WHERE ItemKey = ?;"
        
        var queryStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, stmt, -1, &queryStmt, nil) == SQLITE_OK {
            
            // Binding values
            sqlite3_bind_text(queryStmt, 1, NSString(string: name).utf8String, -1, nil)
            sqlite3_bind_double(queryStmt, 2, price)
            sqlite3_bind_text(queryStmt, 3, NSString(string: type.rawValue).utf8String, -1, nil)
            sqlite3_bind_int(queryStmt, 4, Int32(quantity))
            sqlite3_bind_int(queryStmt, 5, Int32(id))
            
            // Executing the statment
            if sqlite3_step(queryStmt) == SQLITE_DONE {
                // Return the Row ID
                result = 1
            }
        }
        
        sqlite3_finalize(queryStmt)
        sqlite3_close(db)
        return result // Return the result
    }
    
    // Toast
    func showToast(title: String, message: String){
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true,completion: nil)
    }

    @IBAction func quantityStepperTapped(_ sender: Any) {
        itemQuantityTextField.text = Int(quantityStepper.value).description
    }
}


// MARK: -- PICKERVIEW
extension DetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ShopItem.ItemType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ShopItem.ItemType.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        itemTypeTextField.text = ShopItem.ItemType.allCases[row].rawValue
    }
}

