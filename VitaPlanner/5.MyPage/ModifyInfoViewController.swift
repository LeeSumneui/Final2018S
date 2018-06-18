//
//  ModifyInfoViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 5. 27..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit

class ModifyInfoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var textName: UITextField!
    @IBOutlet var textAge: UITextField!
    @IBOutlet var segGender: UISegmentedControl!
    @IBOutlet var textEmail: UITextField!
    
    var changeProfile:Bool = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textName.text = appDelegate.userName
        textAge.text = String(appDelegate.userAge!)
        if appDelegate.userGender == "f" {
            segGender.selectedSegmentIndex = 1
        }
        textEmail.text = appDelegate.userEmail
        var profileName = appDelegate.userProfile
        if (profileName != "") {
            let urlString = "http://condi.swu.ac.kr/student/favorite/"
            profileName = urlString + profileName
            let url = URL(string: profileName)!
            if let imageData = try? Data(contentsOf: url) {
                profileImage.image = UIImage(data: imageData)
                // 웹에서 파일 이미지를 접근함
            } }
    }

    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage.image = image
            changeProfile = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        changeProfile = false
    }

    @IBAction func changProfile(_ sender: UIButton) {
        let alert = UIAlertController(title: "프로필 이미지 변경", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "앨범에서 선택", style: .default, handler:{ aciton in
            let myPicker = UIImagePickerController()
            myPicker.delegate = self
            myPicker.sourceType = .photoLibrary
            self.present(myPicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "이미지 삭제", style: .default, handler:{ action in
            self.profileImage.image = nil
            self.changeProfile = true
        }))
        self.present(alert, animated: true)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func modifyMyInfo(_ sender: Any) {
        var gender = "t"
        var imageFileName: String = ""

        if textName.text == "NULL" {
            let alert = UIAlertController(title: "error", message: "\'NULL\' 아이디로 가입할 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if textAge.text == "" {
            // alert
        }
        if segGender.selectedSegmentIndex == 1 {
            gender = "f"
        }
        if textEmail.text == "" {
            textEmail.text = "null"
        }
        if profileImage.image == nil {
            imageFileName = ""
        }
        
        // 프로필사진 저장
        if(changeProfile == true && profileImage.image != nil) {
            print("2")
            let myImage = profileImage.image
            let myUrl = URL(string: "http://condi.swu.ac.kr/student/favorite/upload.php");
            var request = URLRequest(url:myUrl!);
            request.httpMethod = "POST";
            let boundary = "Boundary-\(NSUUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: "Content-Type")
            guard let imageData = UIImageJPEGRepresentation(myImage!, 1) else { return }
            var body = Data()
            var dataString = "--\(boundary)\r\n"
            dataString += "Content-Disposition: form-data; name=\"userfile\"; filename=\".jpg\"\r\n"
            dataString += "Content-Type: application/octet-stream\r\n\r\n"
            if let data = dataString.data(using: .utf8) { body.append(data) }
            // imageData 위 아래로 boundary 정보 추가
            body.append(imageData)
            dataString = "\r\n"
            dataString += "--\(boundary)--\r\n"
            if let data = dataString.data(using: .utf8) { body.append(data) }
            request.httpBody = body
            
            let semaphore = DispatchSemaphore(value: 0)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (responseData, response, responseError) in
                guard responseError == nil else { print("Error: calling POST"); return; }
                guard let receivedData = responseData else {
                    print("Error: not receiving Data")
                    return; }
                if let utf8Data = String(data: receivedData, encoding: .utf8) { // 서버에 저장한 이미지 파일 이름
                    imageFileName = utf8Data
                    semaphore.signal()
                } }
            task.resume()
            // 이미지 파일 이름을 서버로 부터 받은 후 해당 이름을 DB에 저장하기 위해 wait()
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/changeInfo.php"
        guard let requestURL = URL(string: urlString) else { return }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"

        guard let userID = appDelegate.ID else { return }
        if changeProfile == false {
            imageFileName = appDelegate.userProfile
        }
        var restString: String = "id=" + userID + "&name=" + textName.text!
        restString += "&age=" + textAge.text!
        restString += "&gender=" + String(gender)
        restString += "&email=" + textEmail.text!
        restString += "&profile=" + imageFileName
        request.httpBody = restString.data(using: .utf8)
        print(restString)
        
        let session2 = URLSession.shared
        let task2 = session2.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { return }
            guard let receivedData = responseData else { return }
            if let utf8Data = String(data: receivedData, encoding: .utf8) { print(utf8Data) }
        }
        task2.resume()
        
        // appdelegate 데이터 수정
        appDelegate.userName = textName.text!
        appDelegate.userAge = Int(textAge.text!)
        appDelegate.userGender = String(gender)
        appDelegate.userProfile = imageFileName
        appDelegate.userEmail = textEmail.text!
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
