//
//  UserBoardMainViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 5. 27..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit

class UserBoardMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    var heartCountVar = 0
    var fetchedArray: [BoardData] = Array()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet var boardTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.boardTable.dequeueReusableCell(withIdentifier: "Board Cell", for: indexPath) as! BoardCell
        let item = fetchedArray[indexPath.row]
        cell.title.text = item.title
        cell.name.text = item.id
        cell.date.text = item.date
        cell.content.text = item.content
        cell.keyword.text = item.keyword
        cell.heartCount.text = String(item.heart)
        cell.heartButtonID.tag = Int(item.boardNo)!
        cell.deleteButtonID.tag = Int(item.boardNo)!
        
        if item.id != appDelegate.ID {
            cell.deleteButtonID.isHidden = true
        }
        if item.image != "" {
            let urlString = "http://condi.swu.ac.kr/student/favorite/"
            item.image = urlString + item.image
            let url = URL(string: item.image)!
            if let imageData = try? Data(contentsOf: url) {
                cell.boardImage.image = UIImage(data: imageData)
                // 웹에서 파일 이미지를 접근함
                print("* : \(imageData)")
            }
        }
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchedArray = [] // 배열을 초기화하고 서버에서 자료를 다시 가져옴
        self.downloadDataFromServer()
        print("1:\(fetchedArray.count)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.boardTable.rowHeight = 300
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadDataFromServer() -> Void {
    let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/board/boardTable.php"
        
    guard let requestURL = URL(string: urlString) else { return }
    let request = URLRequest(url: requestURL)
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (responseData, response, responseError) in
    guard responseError == nil else { print("Error: calling POST"); return; }
    guard let receivedData = responseData else {
    print("Error: not receiving Data"); return; }
    let response = response as! HTTPURLResponse
    if !(200...299 ~= response.statusCode) { print("HTTP response Error!"); return }
        do {
            print("do!")
            print(receivedData)
            if let jsonData = try JSONSerialization.jsonObject(with: receivedData,options:.allowFragments) as? [[String: Any]] {
                print("json")
            for i in 0...jsonData.count-1 {
                print("data import")
            let newData: BoardData = BoardData()
            var jsonElement = jsonData[i]
            newData.boardNo = jsonElement["boardNo"] as! String
            newData.title = jsonElement["title"] as! String
            newData.content = jsonElement["content"] as! String
            newData.keyword = jsonElement["keyword"] as! String
            newData.image = jsonElement["image"] as! String
            newData.id = jsonElement["id"] as! String
            newData.date = jsonElement["date"] as! String
            let tempStr = jsonElement["heart"] as! String
            newData.heart = Int(tempStr)!
            self.fetchedArray.append(newData)
        }
                DispatchQueue.main.async { self.boardTable.reloadData() } } 
        } catch { print("Error:"); print("\(error)") } }
    task.resume()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    @IBAction func deleteBoard(_ sender: UIButton) {
        let alert=UIAlertController(title:"정말 삭제 하시겠습니까?", message: "",preferredStyle:.alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .cancel, handler: { action in
            let pressNo = sender.tag
            print(pressNo)
            self.deleteBoardOnServer(boardNo: pressNo)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }

    @IBAction func goToWrite(_ sender: UIButton) {
        if appDelegate.ID == "" {
            let alert = UIAlertController(title: "계정 없음", message: "로그인 후 이용하실 수 있습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "로그인하기", style: .default, handler:{ aciton in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginView = storyboard.instantiateViewController(withIdentifier: "LoginView")
                self.present(loginView, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "뒤로가기", style: .default, handler:nil))
            self.present(alert, animated: true)
            return
        }
        self.performSegue(withIdentifier: "toWritePage", sender: self)
        
    }
    
    @IBAction func pressHeart(_ sender: UIButton) {
        let pressNo = String(sender.tag)
        print(pressNo)
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/pressHeart.php"
        guard let requestURL = URL(string: urlString) else { return }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"

        guard let userID = appDelegate.ID else { return }

        var restString: String = "boardNo=" + pressNo
        
        request.httpBody = restString.data(using: .utf8)
        print(restString)

        let session2 = URLSession.shared
        let task2 = session2.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { return }
            guard let receivedData = responseData else { return }
            if let utf8Data = String(data: receivedData, encoding: .utf8) { print(utf8Data) }
        }
        task2.resume()
    }
    
    func deleteBoardOnServer(boardNo:Int) -> Void {
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/board/deleteBoard.php"
        guard let requestURL = URL(string: urlString) else { return }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        var restString: String = "boardNo=" + String(boardNo)
        
        request.httpBody = restString.data(using: .utf8)
        print(restString)
        
        let session2 = URLSession.shared
        let task2 = session2.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { return }
            guard let receivedData = responseData else { return }
            if let utf8Data = String(data: receivedData, encoding: .utf8) { print(utf8Data) }
        }
        task2.resume()
        
        var selectedRow:Int!
        for i in 0..<fetchedArray.count {
            if boardNo == Int(fetchedArray[i].boardNo) {
                selectedRow = i
            }
        }
        
        self.fetchedArray.remove(at: Int(selectedRow))
        let tempPath = IndexPath.init(row: Int(selectedRow), section: 0)
        self.boardTable.deleteRows(at: [tempPath], with: .fade)
        self.boardTable.reloadData()
    }
}



