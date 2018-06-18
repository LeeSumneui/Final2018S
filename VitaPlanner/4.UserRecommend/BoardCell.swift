//
//  BoardCell.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 6. 2..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit

class BoardCell: UITableViewCell, UITextViewDelegate{

    
   // @IBOutlet var boardElement: Element!
    @IBOutlet var title: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var heartCount: UILabel!
    @IBOutlet var boardImage: UIImageView!
    @IBOutlet var content: UITextView!
    @IBOutlet var keyword: UILabel!
    @IBOutlet var heartButtonID: UIButton!
    @IBOutlet var deleteButtonID: UIButton!
    
    var boardNo:String = "" 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Drawing code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    @IBAction func pressHeart(_ sender: Any) {
        var upCount = Int(heartCount.text!)! + 1
        heartCount.text = String(upCount)
    }
    
}
