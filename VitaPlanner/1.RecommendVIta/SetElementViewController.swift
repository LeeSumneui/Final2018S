//
//  SetElementViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 5. 27..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit

class SetElementViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var segGender: UISegmentedControl!
    @IBOutlet var agePicker: UIPickerView!
    @IBOutlet var labelGender: UILabel!
    @IBOutlet var labelAge: UILabel!
    
    
    var age:[Int] = [10, 20, 30, 40, 50, 60]
    var selectedFunc:UIButton!
    var selectFlag:Bool = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if appDelegate.ID != "" {
            labelAge.text = String(appDelegate.userAge!) + " 세"
            if appDelegate.userGender == "t" {
                labelGender.text = "여 성"
            } else {
                labelGender.text = "남 성"
            }
            labelAge.isHidden = false
            labelGender.isHidden = false
            segGender.isHidden = true
            agePicker.isHidden = true
        }
        // Do any additional setup after loading the view.
        if appDelegate.userGender == "f" {
            segGender.selectedSegmentIndex = 1
        }
        if let age = appDelegate.userAge {
            let rowSet:Int!
            if age < 20 { rowSet = 0 }
            else if age < 30 { rowSet = 1 }
            else if age < 40 { rowSet = 2 }
            else if age < 50 { rowSet = 3 }
            else if age < 60 { rowSet = 4 }
            else { rowSet = 5 }
            agePicker.selectRow(rowSet, inComponent: 0, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // picker setting
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return age.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if age[row] == 10 {
            return String(age[row]) + "대 이하"
        } else if age[row] == 60 {
            return String(age[row]) + "대 이상"
        } else {
            return String(age[row]) + "대"
        }
    }
    
   
    // 기능 선택
    
    @IBAction func funcButtom(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected;

        if selectFlag == true {
            selectedFunc.isSelected = false
            selectedFunc.backgroundColor = UIColor(red:255/255, green: 255/255, blue: 255/255, alpha: 1)
            appDelegate.status = "Null"
        }
        
        if sender.isSelected == true {
            sender.layer.cornerRadius = 40
            sender.backgroundColor = UIColor(red: 231/255, green: 236/255, blue: 242/255, alpha: 1)
            selectFlag = true
            selectedFunc = sender
            print("selected")
            if let selectedStatus = sender.titleLabel?.text {
                print(selectedStatus)
                appDelegate.status = selectedStatus
                print(appDelegate.status)
            }
        } else {
            sender.backgroundColor = UIColor(red:255/255, green: 255/255, blue: 255/255, alpha: 1)
            print("diselected")
            selectFlag = false
            appDelegate.status = "Null"
            }
    }
    
    // 추천 받기 클릭
    @IBAction func pressGo(_ sender: UIButton) {
        if appDelegate.ID == "" {
            appDelegate.userAge = age[agePicker.selectedRow(inComponent: 0)]
            print("age:\(appDelegate.userAge)")
            if segGender.selectedSegmentIndex == 0 {
                appDelegate.userGender = "t"
            } else {
                appDelegate.userGender = "f"
            }
        }
        print("age:\(appDelegate.userAge!)")

        if selectFlag == true {
            self.performSegue(withIdentifier: "goToRlt", sender: self)
        } else {
            let alert = UIAlertController(title:"선택된 상태 없음",message: "상태를 선택하지 않으시겠습니까?",preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.appDelegate.status = "Null"
                self.performSegue(withIdentifier: "goToRlt", sender: self)}))
                
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
