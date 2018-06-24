//
//  WriteBoardViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 5. 27..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit

class WriteBoardViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet var pickerKeyWord: UIPickerView!
    @IBOutlet var selectedImage: UIImageView!
    @IBOutlet var buttonCamera: UIButton!
    @IBOutlet var textTitle: UITextField!
    @IBOutlet var textContent: UITextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let count = appDelegate.NtrList.count
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let keyword = appDelegate.NtrList[row]
        
        return keyword
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // picker.delegate = self
        // Do any additional setup after loading the view.
        if !(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let alert = UIAlertController(title: "Error!!", message: "Device has no Camera!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            buttonCamera.isEnabled = false // 카메라 버튼 사용을 금지시킴
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    

    @IBAction func selectImage(_ sender: UIButton) {
        let myPicker = UIImagePickerController()
        myPicker.delegate = self;
        myPicker.sourceType = .photoLibrary
        self.present(myPicker, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.selectedImage.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel (_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func takePicture(_ sender: UIButton) {
        
        let myPicker = UIImagePickerController()
        myPicker.delegate = self;
        myPicker.allowsEditing = true
        myPicker.sourceType = .camera
        self.present(myPicker, animated: true, completion: nil)
    }
    
    @IBAction func buttonSave(_ sender: UIBarButtonItem) {
        print(textTitle!.text)
        if textTitle.text == "" {
            let alert = UIAlertController(title: "제목을 입력하세요", message: "input title", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return
        }
        if textContent.text == "" {
            let alert = UIAlertController(title: "내용을 입력하세요", message: "input contents", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return
        }
        
        // 이미지 업로드
        guard let myImage = selectedImage.image else {
            let alert = UIAlertController(title: "이미지를 선택하세요",
                                          message: "Save Failed!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                            alert.dismiss(animated: true, completion: nil) }))
            self.present(alert, animated: true)
            return
        }
        
        let myUrl = URL(string: "http://condi.swu.ac.kr/student/favorite/upload.php")
        var request = URLRequest(url:myUrl!);
        request.httpMethod = "POST";
        let boundary = "Boundary-\(NSUUID().uuidString)" // 고유 사용자 식별자

        request.setValue("multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type")
        guard let imageData = UIImageJPEGRepresentation(myImage, 1) else { return }
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

        var imageFileName: String = ""
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
            }
        }
        task.resume()
       //  이미지 파일 이름을 서버로 부터 받은 후 해당 이름을 DB에 저장하기 위해 wait()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        // 내용 업로드
        let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/board/insertContent.php"
        guard let requestURL = URL(string: urlString) else { return }
        
        request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        let userID = appDelegate.ID!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myDate = formatter.string(from: Date())
        let selectedKeyword:String = appDelegate.NtrList[pickerKeyWord.selectedRow(inComponent: 0)]
        
        var restString: String = "id=" + userID
        restString += "&title=" + textTitle.text!
        restString += "&keyword=" + selectedKeyword
        restString += "&content=" + textContent.text
        restString += "&image=" + imageFileName
        restString += "&date=" + myDate
        request.httpBody = restString.data(using: .utf8)
        let session2 = URLSession.shared
        let task2 = session2.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { print("Error: calling POST"); return }
            guard let receivedData = responseData else { print("Error: not receiving Data"
                ); return }
            if let utf8Data = String(data: receivedData, encoding: .utf8) { print(utf8Data) }

            }
        
       task2.resume()
       _ = self.navigationController?.popViewController(animated: true)
    }

}
    
    


