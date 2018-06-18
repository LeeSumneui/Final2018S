//
//  JoinViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 6. 5..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit



class JoinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textID: UITextField!
    @IBOutlet var textPassword: UITextField!
    @IBOutlet var textName: UITextField!
    @IBOutlet var textAge: UITextField!
    @IBOutlet var segmentGender: UISegmentedControl!
    @IBOutlet var textEmail: UITextField!
    
    var gender:Bool = true
    
    func textFieldShouldReturn (_ textField: UITextField) -> Bool {
        if textField == self.textID { textField.resignFirstResponder()
            self.textPassword.becomeFirstResponder()
        }
        else if textField == self.textPassword {
            textField.resignFirstResponder()
            self.textName.becomeFirstResponder()
        } else if textName == self.textName {
            textField.resignFirstResponder()
            self.textAge.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        }
    
    @IBAction func buttonCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSave(_ sender: UIButton) {
        if textID.text == "" {
            let alert = UIAlertController(title: "필수 항목 입력", message: "아이디를 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if textPassword.text == "" {
            let alert = UIAlertController(title: "필수 항목 입력", message: "비밀번호를 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if textName.text == "" {
            let alert = UIAlertController(title: "필수 항목 입력", message: "이름을 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if textAge.text == "" {
            let alert = UIAlertController(title: "필수 항목 입력", message: "나이를 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if segmentGender.selectedSegmentIndex == 1 {
            gender = false
        }
        if textEmail.text == "" {
            textEmail.text = "null"
        }
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/login/insertUser.php"
        guard let requestURL = URL(string: urlString)
        else {
            return
        }
        print(requestURL)
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        let restString: String = "id=" + textID.text! + "&password=" + textPassword.text!
            + "&name=" + textName.text! + "&age=" + textAge.text! + "&gender=" + String(gender) + "&email=" + textEmail.text!
        
        print("\(textPassword.text!)")
        request.httpBody = restString.data(using: .utf8)
        self.executeRequest(request: request)
        self.dismiss(animated: true, completion: nil)
    }
    
    func executeRequest (request: URLRequest) -> Void {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { print("Error: calling POST")
                return }
            guard let receivedData = responseData else { print("Error: not receiving Data")
                return }
            if let utf8Data = String(data: receivedData, encoding: .utf8) { DispatchQueue.main.async { // for Main Thread Checker
                
                print(utf8Data) // php에서 출력한 echo data가 debug 창에 표시됨
                }
            }
        }
            task.resume()
    }

}
