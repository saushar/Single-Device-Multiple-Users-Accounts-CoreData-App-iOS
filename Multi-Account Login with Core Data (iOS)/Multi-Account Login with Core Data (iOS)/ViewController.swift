//
//  ViewController.swift
//  Multi-Account Login with Core Data (iOS)
//
//  Created by SAURABH SHARMA on 26/03/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameTxtf: UITextField!
    @IBOutlet weak var passwordTxtf: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let email = UserDefaults.standard.string(forKey: "loggedInUser")
        if email != nil {
            loginTapped()
            self.performSegue(withIdentifier: "successSegue", sender: nil)
        }
    }

    @IBAction func login() {
        guard self.usernameTxtf.text?.isEmpty == false
                || self.passwordTxtf.text?.isEmpty == false else {
            return
        }
        AccountViewModel.shared.currentUser = LoginUser(email: usernameTxtf.text, password: passwordTxtf.text)
        self.loginTapped()
        self.performSegue(withIdentifier: "successSegue", sender: nil)
    }
    
    func loginTapped() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let _ = app.persistentContainer
        AppDelegate.semaphore.wait()
        let _ = app.setupNewContainer(completion: {})
        UserDefaults.standard.setValue(AccountViewModel.shared.currentUser.email, forKey: "loggedInUser")
        UserDefaults.standard.synchronize()
    }
}

