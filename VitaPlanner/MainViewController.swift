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
    
    // ************
    @IBOutlet var status: UITextField!
    @IBOutlet var ntrName: UITextField!
    @IBOutlet var ageCont: UITextField!
    @IBOutlet var genderCont: UITextField!
    @IBOutlet var addDesc: UITextView!
    // ************

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        if appDelegate.ID == "" {
            name.isHidden = true
        }
        name.text = appDelegate.userName! + "님 안녕하세요~!"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    
    @IBAction func goToMyPage(_ sender: UIButton) {
        print("2")
        if appDelegate.ID == "" {
            print("1")
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
    
}
