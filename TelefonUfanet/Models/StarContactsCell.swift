//
//  StarContactsModel.swift
//  TelefonUfanet
//
//  Created by Almaz on 09/06/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit

class StarContactsCell: UITableViewCell {

  
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Number: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
