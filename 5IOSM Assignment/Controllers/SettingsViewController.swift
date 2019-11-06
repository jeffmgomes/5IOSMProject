//
//  SettingsViewController.swift
//  5IOSM Assignment
//
//  Created by Jefferson MARINHO GOMES (001088479) on 11/9/19.
//  Copyright © 2019 Jefferson MARINHO GOMES (001088479). All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var colorSlider: UISlider!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    let colorArray = [0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        self.saveButtonOutlet.layer.cornerRadius = 5
        
        self.displayView.layer.cornerRadius = 7
        self.displayView.layer.borderWidth = 2
        self.displayView.layer.borderColor = UIColor.black.cgColor

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
        Colour.sharedInstance.selectedColour = uiColorFromHex(rgbValue: colorArray[Int(colorSlider.value)])
        self.view.backgroundColor = Colour.sharedInstance.selectedColour
    }
    
    @IBAction func colorSliderValueChanged(_ sender: UISlider) {
        self.displayView.backgroundColor = uiColorFromHex(rgbValue: colorArray[Int(colorSlider.value)])
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor
    {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue = CGFloat((rgbValue & 0x0000FF)) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
