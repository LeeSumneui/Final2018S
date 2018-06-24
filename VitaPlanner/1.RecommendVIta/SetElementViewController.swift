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

        // 상태는 중복 선택할 수 없음.
        // 따라서 이미 상태가 선택 된 상태에서 다른 상태를 선택했을 때 이미 선택되었던 버튼은 선택 해제를 시켜줘야 한다.
        if selectFlag == true { // 상태가 이미 선택된 상태였다면
            selectedFunc.isSelected = false // 이미 선택되었던 status 버튼의 selected 상태를 false로 만들어줌
            // '선택되지 않음'을 나타내는 white로 배경 변경
            selectedFunc.backgroundColor = UIColor(red:255/255, green: 255/255, blue: 255/255, alpha: 1)
            appDelegate.status = "Null" // appdelegate에 선언되어있는 status 변수를 'Null' 로 바꿔줌
        }
        
        if sender.isSelected == true {  // 클릭한 status 버튼의 selected 상태를 true일 경우
            // '선택됨'을 나타내는 색깔로 배경 변경
            sender.layer.cornerRadius = 40 // 레이어를 동그랗게 바꿔줌
            sender.backgroundColor = UIColor(red: 231/255, green: 236/255, blue: 242/255, alpha: 1)
            
            selectFlag = true // flag 변수를 true 로 변경
            selectedFunc = sender // 선택한 버튼을 selectedFunc 변수에 넣어줌
            print("selected")
            // appdelegate에 선언되어 있는 status 변수를 상태이름으로 바꿔줌
            if let selectedStatus = sender.titleLabel?.text {
                appDelegate.status = selectedStatus
            }
        } else {  // 직접 선택 해제를 했을 때 (sender.isSelected == false 일 경우)
            sender.backgroundColor = UIColor(red:255/255, green: 255/255, blue: 255/255, alpha: 1)
            print("diselected")
            selectFlag = false // selectFlag 변수를 false 로 변경
            appDelegate.status = "Null"
            }
    }
    
    // 추천 받기 클릭
    @IBAction func pressGo(_ sender: UIButton) {
        if appDelegate.ID == "" {
            appDelegate.userAge = age[agePicker.selectedRow(inComponent: 0)]
            if segGender.selectedSegmentIndex == 0 {
                appDelegate.userGender = "t"
            } else {
                appDelegate.userGender = "f"
            }
        }

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
