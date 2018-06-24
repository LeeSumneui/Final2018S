//
//  CustomListViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 5. 27..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit

class CustomListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate {
    
    @IBOutlet var NtrTable: UITableView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var barTitle: UINavigationItem!
    
    var isStatus:Bool = true
    // server에서 받아온 데이터 저장
    var fetchedArray: [RecommendData] = Array()
    // 나이, 성별조건에 따라 필터링 한 데이터 저장
    var finalArray: [RecommendData] = Array()
    // 중복 검사후 필터링 한 영양소 이름 저장
    var finalNameArray:[String] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.NtrTable.dequeueReusableCell(withIdentifier: "Nutrient Cell", for: indexPath)
        cell.textLabel?.text = finalNameArray[indexPath.row]

        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if appDelegate.ID == "" {
            appDelegate.userName = "사 용 자"
        }
        
        labelName.text = appDelegate.userName
        barTitle.title = appDelegate.status
        
        if appDelegate.status == "Null" { // status를 선택하지 않고 넘어온 경우
            isStatus = false
            if let selectedAge = appDelegate.userAge { // 나이대 별로 추천리스트를 출력하도록 해줌
                if selectedAge < 20 {appDelegate.status = "teen"}
                else if selectedAge < 40 {appDelegate.status = "young"}
                else if selectedAge < 60 {appDelegate.status = "middle"}
                else if selectedAge >= 60 {appDelegate.status = "old"}
            }
        }
        self.downloadDataFromServer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func downloadDataFromServer() -> Void {
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/recommendTable.php"
        
        guard let requestURL = URL(string: urlString) else { return }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        let restString: String = "status=" + appDelegate.status
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
                        let newData: RecommendData = RecommendData()
                        var jsonElement = jsonData[i]
                        newData.name = jsonElement["ntrName"] as! String
                        newData.genderCont = jsonElement["genderCont"] as! String
                        if newData.genderCont == "1" {
                            newData.genderCont = "t"
                        } else if newData.genderCont == "2" {
                            newData.genderCont = "f"
                        }
                        newData.descript = jsonElement["description"] as! String
                        let tempStr = jsonElement["ageCont"] as! String
                        newData.ageCont = Int(tempStr)!
                        self.fetchedArray.append(newData)
                    }
                    DispatchQueue.main.async {
                            self.finalResult(age:self.appDelegate.userAge!, gender:self.appDelegate.userGender!)
                        self.NtrTable.reloadData() }
                    print("success~!")
                }
            } catch { print("Error:") } }
        task.resume()
    }
    
    func finalResult(age:Int, gender:String) -> Void {
        print("finalResult()")
        
        for i in 0..<fetchedArray.count {
         var PassAge = false
         var PassGender = false
            if isStatus == true { // status 선택을 하고 넘어온 경우
                print("나이 조건 검사")
                // 배열 수 만큼 나이로 걸러내기
                if fetchedArray[i].ageCont == 0 { PassAge = true }
                if fetchedArray[i].ageCont == 10 {
                    if appDelegate.userAge == 10 { PassAge = true }
                    else { PassAge = false; print("성인이므로 삭제") // 10대이하가 아니면 삭제
                    }
                }else if fetchedArray[i].ageCont > appDelegate.userAge! { //나이 조건이 설정 나이보다 많을 때
                    PassAge = false; print("조건보다 나이가 적으므로 삭제")
                }else {  //나이 조건이 설정 나이보다 적을 때
                    PassAge = true; print("유지!")
                }
            } else { PassAge = true }
            // 성별로 걸러내기
            print("성별 조건 검사")
            if fetchedArray[i].genderCont == "0" {
                PassGender = true
            } else if fetchedArray[i].genderCont != (appDelegate.userGender!) {
                PassGender = false
                print("성별땜에 삭제 : \(fetchedArray[i].description)")
            } else if fetchedArray[i].genderCont == (appDelegate.userGender!) {
                PassGender = true
            }
            
            if PassGender == true && PassAge == true {
                finalArray.append(fetchedArray[i])
            }
        }
        dupCheck()
    }
    
    func dupCheck() -> Void {
        let count = finalArray.count
        
        for i in 0..<count {
            let count2 = finalNameArray.count
            var insert = true
            for j in 0..<count2 {
                if finalArray[i].name == finalNameArray[j] { insert = false; print("이름 중복 삭제"); break}
            }
            if finalArray[i].name == "" { insert = false } // 설명을 위한 데이터의 이름은 삭제
            
            if insert == true { finalNameArray.append(finalArray[i].name) }
        }
        return
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toDetailView" {
            if let tabbar = segue.destination as? UITabBarController {
                let destination = tabbar.childViewControllers[0] as! NtrDetailViewController
                if let selectedIndex = self.NtrTable.indexPathsForSelectedRows?.first?.row {
                    destination.ntrName = finalNameArray[selectedIndex]
                }
            }
        }
        if segue.identifier == "toPrecription" {
            if let destination = segue.destination as? PrescriptionViewController {
                var str:String = ""
                for i  in 0..<finalArray.count {
                    str += "* " + finalArray[i].descript + "     \n\n"
                }
                destination.detailStr = str
            }
        }
    }
    
    
}
