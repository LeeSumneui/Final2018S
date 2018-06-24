//
//  LoginViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 6. 5..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var loginUserid: UITextField!
    @IBOutlet var loginPassword: UITextField!
    @IBOutlet var loginStatus: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var User: [NSManagedObject] = []
    var loginStatusStr:String?
    
    func getContext () -> NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // core data에 저장되어있는 id가 있으면(이미 로그인 되어있는 경우) 바로 main화면으로 이동
        self.loginStatus.isHidden = true
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ValidID")
    
        do {
            User = try context.fetch(fetchRequest)
            print(User.count)

            if User.count > 0 {
            let validId = User[0].value(forKey: "userID") as! String
            let validPw = User[0].value(forKey: "userPW") as! String
            print(validId)
            print(validPw)
            login(id: validId, pw: validPw, auto: true)
            }
        } catch {
           
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.loginUserid {
            textField.resignFirstResponder()
            self.loginPassword.becomeFirstResponder()
        }
        textField.resignFirstResponder()
        return true
    }
    

    @IBAction func loginPressed() {
        if loginUserid.text == "" {
            // alert
            let alert = UIAlertController(title: "필수 항목 입력", message: "아이디를 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if loginPassword.text == "" {
            // alert
            let alert = UIAlertController(title: "필수 항목 입력", message: "비밀번호를 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // 둘 다 입력한 경우 로그인 함수 호출
        login(id:loginUserid.text!, pw:loginPassword.text!, auto: false)
        
    }
    
    // '계정 없이 사용하기' 를 클릭한 경우
    @IBAction func noAccount(_ sender: UIButton) {
        self.appDelegate.ID = ""
        self.appDelegate.userName = ""
        self.appDelegate.userAge = 0
        self.appDelegate.userGender = ""
        self.appDelegate.userEmail = "Null"
        self.appDelegate.userProfile = ""

        self.performSegue(withIdentifier: "toLoginSuccess", sender: self)
    }
    
    // 로그인 처리를 해주는 함수
    func login(id:String, pw:String, auto:Bool) -> Void {
        
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/login/loginUser.php"
        guard let requestURL = URL(string: urlString)
            else {
                return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        let restString: String = "id=" + id + "&password=" + pw
        
        request.httpBody = restString.data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { print("Error: calling POST")
                return }
            guard let receivedData = responseData else { print("Error: not receiving Data")
                return }
            do {
                let response = response as! HTTPURLResponse
                if !(200...299 ~= response.statusCode) {
                    print ("HTTP Error!")
                    return }
                
                guard let jsonData = try JSONSerialization.jsonObject(with: receivedData, options:.allowFragments)as? [String: Any] else {
                    print("JSON Serialization Error!")
                    return }
                
                guard let success = jsonData["success"] as! String? else { print("Error: PHP failure(success)")
                    return }
                
                
                if success == "YES" {
                    
                DispatchQueue.main.async {
                    if let name = jsonData["name"] as! String? {
                        self.appDelegate.ID = id
                        self.appDelegate.userName = name
                    }
                    if let age = jsonData["age"] as! String? {
                        self.appDelegate.userAge = Int(age)
                    }
                    if let gender = jsonData["gender"] as! String? {
                        self.appDelegate.userGender = gender
                    }
                    if let email = jsonData["email"] as! String? {
                        self.appDelegate.userEmail = email
                    }
                    if let profile = jsonData["profileImage"] as! String? {
                        self.appDelegate.userProfile = profile
                    }
                    
                    // 로그인 성공시 coreData에 userid/password 저장 (자동 로그인인 경우 안함)
                    if auto == false {
                        let context = self.getContext()
                        let entity = NSEntityDescription.entity(forEntityName: "ValidID", in: context)
                        let object = NSManagedObject(entity: entity!, insertInto: context)
                        
                        object.setValue(self.loginUserid.text, forKey: "userID")
                        object.setValue(self.loginPassword.text, forKey: "userPW")
                        
                        do {
                            try context.save()
                            print("coreDB saved!")
                        } catch let error as NSError {
                            print("(CoreDB)Could not save \(error), \(error.userInfo)")
                        }
                    }
                    
                    self.performSegue(withIdentifier: "toLoginSuccess", sender: self)
                }
            } else {
                DispatchQueue.main.async {
                    if let errMessage = jsonData["error"] as! String! {
                        print("\(errMessage)")
                        self.loginStatus.isHidden = false
                        self.loginStatus.text = "ID not exist!"
                        }
                    if let errMessage2 = jsonData["error2"] as! String! {
                        self.loginStatus.isHidden = false
                        print("\(errMessage2)")
                        self.loginStatus.text = "PW not correct!"
                        }
                    }
                }
            } catch {
                print("Error: \(error)") }
            }
        task.resume()
    }
    
}
