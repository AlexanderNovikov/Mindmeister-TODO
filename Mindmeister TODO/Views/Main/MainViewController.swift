//
//  ViewController.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 14.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let session = SessionService.shared.getSession() {
            MMApiService.shared.getTokenInfo(session: session) { (res) in
                DispatchQueue.main.async {
                    if (res) {
                        self.performSegue(withIdentifier: MapsViewController.SEGUE_SHOW_MAPS, sender: nil)
                    } else {
                        self.loginButton.isHidden = false
                        SessionService.shared.removeSession()
                    }
                }
            }
        } else {
            self.loginButton.isHidden = false
        }
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showLogin", sender: nil)
    }
}

