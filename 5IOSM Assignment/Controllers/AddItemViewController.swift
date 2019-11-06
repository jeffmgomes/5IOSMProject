//
//  AddItemViewController.swift
//  5IOSM Assignment
//
//  Created by Jefferson MARINHO GOMES (001088479) on 11/9/19.
//  Copyright © 2019 Jefferson MARINHO GOMES (001088479). All rights reserved.
//

import UIKit
import SQLite3

protocol AddItemDelegate {
    func didSaveItem(item: ShopItem)
}

class AddItemViewController: UIViewController {
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var stepperValue: UIStepper!
    
    var delegate: AddItemDelegate?
    
    var db: OpaquePointer? = nil
    
    let pickerView = UIPickerView() // Create a pickerview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        quantityTextField.text = Int(stepperValue.value).description
        
        guard connectToDB() else {
            print("Error connecting")
            return
        }
        
        
        pickerView.delegate = self // Set this controller as the delegate
        typeTextField.delegate = self
        // Set the pickerview as the input view of the textfield
        typeTextField.inputView = pickerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = Colour.sharedInstance.selectedColour
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let name = nameTextField.text, !name.isEmpty else {
            self.showToast(title: "Field Required", message: "Item Name is required!")
            return
        }
        
        guard let price = Double(priceTextField.text!), !price.isNaN else {
            self.showToast(title: "Field Required", message: "Price is required!")
            return
        }
        
        guard let quantity = Int(quantityTextField.text!), quantity > 0 else {
            self.showToast(title: "Field Required", message: "Quantity is required!")
            return
        }
        
        guard let type = typeTextField.text, !type.isEmpty else {
            self.showToast(title: "Field Required", message: "Type is required!")
            return
        }
        
        let id = insertItem(name: name, price: price, type: ShopItem.ItemType(rawValue: type) ?? .Other, quantity: quantity)
        
        if id != 0 {
            let item = ShopItem(id: id, name: name, price: price, type: ShopItem.ItemType(rawValue: type) ?? .Other, quantity: quantity)
            
            self.delegate?.didSaveItem(item: item)
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func stepperTapped(_ sender: Any) {
        quantityTextField.text = Int(stepperValue.value).description
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
    func insertItem(name: String, price: Double, type: ShopItem.ItemType, quantity: Int) -> Int
    {
        var result: Int = 0 // Variable to return the result
        
        let stmt = "INSERT INTO List (ItemKey, ItemName, ItemPrice, ItemType, Quantity) VALUES (NULL, ?, ?, ?, ?);"
        
        var queryStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, stmt, -1, &queryStmt, nil) == SQLITE_OK {
            
            // Binding values
            sqlite3_bind_text(queryStmt, 1, NSString(string: name).utf8String, -1, nil)
            sqlite3_bind_double(queryStmt, 2, price)
            sqlite3_bind_text(queryStmt, 3, NSString(string: type.rawValue).utf8String, -1, nil)
            sqlite3_bind_int(queryStmt, 4, Int32(quantity))
            
            // Executing the statment
            if sqlite3_step(queryStmt) == SQLITE_DONE {
                // Return the Row ID
                result = Int(sqlite3_last_insert_rowid(db))
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
}

// MARK: -- PickerView Delegate

extension AddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        typeTextField.text = ShopItem.ItemType.allCases[row].rawValue
    }
}

// MARK: -- TextField Delegate

extension AddItemViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            typeTextField.text = ShopItem.ItemType.allCases[0].rawValue
        }
    }
}
