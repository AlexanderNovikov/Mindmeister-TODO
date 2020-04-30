//
//  IdeaTableViewCell.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 29.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import UIKit

class IdeaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ideaTitleLabel: UILabel!
    @IBOutlet weak var ideaIconLabel: UILabel!
    
    var idea: MapIdea? {
        didSet {
            if let idea = idea {
                self.ideaTitleLabel.text = idea.title
                var icon = ""
                switch idea.icon {
                case MapIdea.ICON_STATUS_OK:
                    icon = "✅"
                default:
                    icon = ""
                }
                self.ideaIconLabel.text = icon
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
