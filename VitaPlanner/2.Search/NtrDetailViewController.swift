//
//  NtrDetailViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 5. 27..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit
import CoreData

class NtrDetailViewController: UIViewController {

    @IBOutlet var takingButton: UIButton!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var textNtrData: UITextView!
    
    var ntrName:String!
    var ntrData:String!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //ntrName = "비타민D"
        if appDelegate.ID == "" { takingButton.isHidden = true }
        labelName.text = ntrName
        
        downloadDataFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressTaking(_ sender: UIButton) {
        
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/test.php"
        guard let requestURL = URL(string: urlString)
            else {
                return
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        let restString: String = "id=" + appDelegate.ID! + "&ntrName=" + self.ntrName
        
        request.httpBody = restString.data(using: .utf8)
        self.executeRequest(request: request)
    }
    
    func executeRequest (request: URLRequest) -> Void {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { print("Error: calling POST")
                return }
            guard let receivedData = responseData else { print("Error: not receiving Data")
                return }
            do {
                print("2")
                
                let response = response as! HTTPURLResponse
                if !(200...299 ~= response.statusCode) {
                    print ("HTTP Error!")
                    print(response.statusCode)
                    return }
                print("3")
                
                print(receivedData)
                guard let jsonData = try JSONSerialization.jsonObject(with: receivedData, options:.allowFragments) as? [String: Any] else {
                    print("JSON Serialization Error!")
                    return }
                
                print("4")
                
                guard let duplicate = jsonData["duplicate"] as! String! else { print("Error: PHP failure(success)")
                    return }
                print("6")
                
                 if let utf8Data = String(data: receivedData, encoding: .utf8) { print(utf8Data) }
                
                if duplicate == "YES" {
                    print("5")
                    // error Massage
                    let alert = UIAlertController(title:"중복",message: "이미 복용중 입니다.",preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                    self.present(alert, animated: true)
                    return
                } else if duplicate == "NO" {
                    // 성공적으로 추가! 라는 알림창 띄우기
                    let alert = UIAlertController(title:"성공",message: "복용 리스트에 추가했습니다.",preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                    self.present(alert, animated: true)
                   
//                    let tabController = UITabBarController()
//                    let tableVC = tabController.childViewControllers[1] as! TakeListViewController
//                    print("복용갯수 : \(tableVC.myTakingList.count)")
//                    tableVC.listTab.badgeValue = String(format: "%d", tableVC.myTakingList.count)
                }
            } catch {
                print("Error: \(error)")
            }
        }
        task.resume()
    }

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func downloadDataFromServer() -> Void {
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/loadNtrData.php"
        guard let requestURL = URL(string: urlString)
            else {
                return
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        print("보내는 데이터 : \(ntrName!)")
        let restString: String = "ntrName=" + ntrName!
        
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
                    print(response.statusCode)
                    return }
                  print("4")
                
                guard let jsonData = try JSONSerialization.jsonObject(with: receivedData, options:.allowFragments) as? [String: Any] else {
                    print("JSON Serialization Error!")
                    return }
                
                guard let success = jsonData["success"] as! String! else { print("Error: PHP failure(success)")
                    return }
                print("1")
                
                if success == "YES" {
                    print("2")
                    DispatchQueue.main.async {
                        print(jsonData["data"])
                        if let data = jsonData["data"] as! String! {
                            self.textNtrData.text = data
                        }
                    }
                } else {
                    if let errMessage = jsonData["error"] as! String! {
                        print("\(errMessage)")
                        //DispatchQueue.main.async { }
                    }
                }
            } catch {
                print("Error: \(error)") }
        }
        task.resume()
    }
    
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
