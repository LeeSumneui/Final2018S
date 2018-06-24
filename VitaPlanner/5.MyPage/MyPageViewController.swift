//
//  MyPageViewController.swift
//  VitaPlanner
//
//  Created by 이수민 on 2018. 5. 27..
//  Copyright © 2018년 이수민. All rights reserved.
//

import UIKit
import CoreData

class MyPageViewController: UIViewController {

    @IBOutlet var profile: UIImageView!
    @IBOutlet var labelID: UILabel!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelGender: UILabel!
    @IBOutlet var labelAge: UILabel!
    
    var User: [NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profile.layer.cornerRadius = 70
        profile.layer.masksToBounds = true
        
        // 이 코드 삭제하면 1개 이상의 데이터가 저장됨
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ValidID")
        do {
            User = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var imageName = appDelegate.userProfile

        labelID.text = appDelegate.ID
        labelName.text = appDelegate.userName

        let gender = appDelegate.userGender
        if (gender == "t" || gender == "true") {
            labelGender.text = "여"
            labelGender.textColor = UIColor.red
        } else {
            labelGender.text = "남"
            labelGender.textColor = UIColor.blue
        }
        labelAge.text = String(appDelegate.userAge!) + " 세"

        if (imageName != "") {
            print("이미지 로드중")
            let urlString = "http://condi.swu.ac.kr/student/favorite/"
            imageName = urlString + imageName
            let url = URL(string: imageName)!
            if let imageData = try? Data(contentsOf: url) {
                print("이미지 로드중")
                profile.image = UIImage(data: imageData)
                // 웹에서 파일 이미지를 접근함
            }
        } else {
            profile.image = nil
        }
    }
    
    func getContext () -> NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext }
    
    @IBAction func buttonLogout(_ sender: UIButton) {
        let alert = UIAlertController(title:"로그아웃 하시겠습니까?",message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            let urlString: String = "http://condi.swu.ac.kr/student/W08iphone/login/logout.php"
            guard let requestURL = URL(string: urlString) else { return }
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (responseData, response, responseError) in
                guard responseError == nil else { return } }
            task.resume()
            
            let context = self.getContext()
            
            if self.User.count > 0 {
                context.delete(self.User[0])
                do {
                    try context.save()
                    print("deleted!")
                } catch let error as NSError {
                    print("Could not delete \(error), \(error.userInfo)") }
                // 배열에서 해당 자료 삭제
                self.User.remove(at: 0)
                
            }
            self.appDelegate.ID = ""
            self.appDelegate.MyTakingList = []
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginView = storyboard.instantiateViewController(withIdentifier: "LoginView")
        self.present(loginView, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
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

}
