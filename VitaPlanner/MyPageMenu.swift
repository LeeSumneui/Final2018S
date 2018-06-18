//
//  MyPageMenu.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 6. 2..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit

class MyPageMenu: UIView, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.menuTable.dequeueReusableCell(withIdentifier: "Menu Cell", for: indexPath)
        
        return cell
    }
    

    @IBOutlet var profileImage:UIImageView!
    @IBOutlet var menuTable:UITableView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
