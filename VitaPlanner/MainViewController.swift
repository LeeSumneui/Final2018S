//
//  ViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 5. 14..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var name: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        if appDelegate.ID == "" {
            name.isHidden = true
        } else { downloadDataFromServer() }
        name.text = appDelegate.userName! + "님 안녕하세요~!"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    
    @IBAction func goToMyPage(_ sender: UIButton) {
        if appDelegate.ID == "" {
            let alert = UIAlertController(title: "계정 없음", message: "로그인 후 이용하실 수 있습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "로그인하기", style: .default, handler:{ aciton in 
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginView = storyboard.instantiateViewController(withIdentifier: "LoginView")
                self.present(loginView, animated: true, completion: nil)
                }))
            alert.addAction(UIAlertAction(title: "뒤로 가기", style: .default, handler:{ aciton in
                return }))
            self.present(alert, animated: true)
            return
        }
        self.performSegue(withIdentifier: "toMyPage", sender: self)
        
    }
    
    func downloadDataFromServer() -> Void {
            let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/myTakingList.php"
    
            guard let requestURL = URL(string: urlString) else { return }
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            let restString: String = "id=" + appDelegate.ID!
            request.httpBody = restString.data(using: .utf8)
    
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (responseData, response, responseError) in
                guard responseError == nil else { print("Error: calling POST"); return; }
                guard let receivedData = responseData else {
                    print("Error: not receiving Data"); return; }
                let response = response as! HTTPURLResponse
                if !(200...299 ~= response.statusCode) { print("HTTP response Error!");
                    print("\(response.statusCode)")
                    return }
                do {
                    if let jsonData = try JSONSerialization.jsonObject (with: receivedData,options:.allowFragments) as? [[String: Any]] {
                        for i in 0...jsonData.count-1 {
                            var jsonElement = jsonData[i]
                            let newData:String = jsonElement["ntrName"] as! String
    
                            self.appDelegate.MyTakingList.append(newData)
                        }
                        print("success~!")
                    }
                } catch { print("Error:") } }
            task.resume()
        }
    
}
