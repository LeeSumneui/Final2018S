//
//  TakeListViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 5. 27..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit

class TakeListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var ListTable: UITableView!
    @IBOutlet var listTab: UITabBarItem!
    
    var myTakingList:[String] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if appDelegate.ID == "" {
            let alert = UIAlertController(title: "계정 없음", message: "로그인 후 이용하실 수 있습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "로그인하기", style: .default, handler:{ aciton in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginView = storyboard.instantiateViewController(withIdentifier: "LoginView")
                self.present(loginView, animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
            return
        }
        myTakingList = [] // 배열을 초기화하고 서버에서 자료를 다시 가져옴
        self.downloadDataFromServer()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTakingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.ListTable.dequeueReusableCell(withIdentifier: "Taking Cell", for: indexPath)
        if let name = myTakingList[indexPath.row] as? String {
            cell.textLabel?.text = name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 자료구조에서 삭제
            let alert=UIAlertController(title:"정말 삭제 하시겠습니까?", message: "",preferredStyle:.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .cancel, handler: { action in
                self.deleteElement(ntrName:self.myTakingList[indexPath.row])
                
                self.myTakingList.remove(at: indexPath.row)
                self.ListTable.deleteRows(at: [indexPath], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                print("do!")
                if let jsonData = try JSONSerialization.jsonObject (with: receivedData,options:.allowFragments) as? [[String: Any]] {
                    print("1")
                    for i in 0...jsonData.count-1 {
                        var jsonElement = jsonData[i]
                        let newData:String = jsonElement["ntrName"] as! String
                        
                        self.myTakingList.append(newData)
                        print(newData)
                    }
                    DispatchQueue.main.async { self.ListTable.reloadData() }
                    print("success~!")
                }
            } catch { print("Error:") } }
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

    func deleteElement(ntrName: String?) -> Void {
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/deleteTakingNtr.php"
        guard let requestURL = URL(string: urlString) else { return }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        guard let name = ntrName else { return }
        let restString: String = "ntrName=" + name
        request.httpBody = restString.data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (responseData, response, responseError) in guard responseError == nil else { return }
            guard let receivedData = responseData else { return }
            if let utf8Data = String(data: receivedData, encoding: .utf8) { print(utf8Data) }
        }
        task.resume()
    }
}
