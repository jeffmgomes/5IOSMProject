//
//  CellTableViewCell.swift
//  5IOSM Assignment
//
//  Created by Jefferson Gomes on 23/10/19.
//  Copyright © 2019 Jefferson MARINHO GOMES (001088479). All rights reserved.
//

import UIKit

class CellTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    
    var item: ShopItem! {
        didSet {
            self.updateUI()
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI()
    {
        itemNameLabel.text = item.name
        itemPriceLabel.text = NumberFormatter.localizedString(from: NSNumber(value: item.price!), number: .currency)
        itemQuantityLabel.text = String(item.quantity!)
    }

}
