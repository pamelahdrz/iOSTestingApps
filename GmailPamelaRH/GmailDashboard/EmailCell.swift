//
//  EmailCell.swift
//  GmailPamelaRH
//
//  Created by Razo Hernandez Pamela on 08/07/23.
//

import UIKit

class EmailCell: UITableViewCell {
    @IBOutlet weak var starredImage: UIImageView!
    @IBOutlet weak var starredButton: UIButton!
    @IBOutlet weak var spamImage: UIImageView!
    @IBOutlet weak var spamButton: UIButton!
    @IBOutlet weak var garbageImage: UIImageView!
    @IBOutlet weak var garbageButton: UIButton!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var emailSubject: UILabel!
    @IBOutlet weak var emailHeader: UILabel!
    @IBOutlet weak var receivedTime: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
