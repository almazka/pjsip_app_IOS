//
//  WorkedContactCell.swift
//  TelefonUfanet
//
//  Created by Almaz on 03/06/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit

class WorkedContactCell: UITableViewCell {
    
    
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var Number: UILabel!
    
    @IBOutlet weak var Description: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
