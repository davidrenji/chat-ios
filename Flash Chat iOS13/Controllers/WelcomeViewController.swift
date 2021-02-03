//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import CLTypingLabel
import Firebase

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: CLTypingLabel!
    
    let userData = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Verify if the firebase session is still opened to redirect
        if Auth.auth().currentUser?.uid != nil {
            self.performSegue(withIdentifier: Constants.welcomeToChat, sender: self)
        }
        
        //Using the 3rd party library CLTypingLabel we get the same effect for the code below
        titleLabel.text = Constants.appName
        
        
//        titleLabel.text = ""
//        var characterIndex = 1
//        let title = "⚡️FlashChat"
//        for letter in title {
//            Timer.scheduledTimer(withTimeInterval: 0.1 * Double(characterIndex), repeats: false) { (timer) in
//                self.titleLabel.text?.append(letter)
//            }
//            characterIndex += 1
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

}
