//
//  MapTableViewCell.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 27.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import UIKit

class MapTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mapTitleLabel: UILabel!
    
    var map: MapListMap? {
        didSet {
            if let map = map {
                self.mapTitleLabel.text = map.title
            }
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
    
}
