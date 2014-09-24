//
//  ViewController.swift
//  FxASwiftly
//
//  Created by Richard Newman on 2014-09-22.
//  Copyright (c) 2014 Mozilla. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var myEmail: UITextField!
    @IBOutlet weak var myPassword: UITextField!
    @IBOutlet weak var myError: UILabel!

    @IBAction func mySignIn(sender: AnyObject) {
        myError.text = NSString(format: "%@, %@", myEmail.text, myPassword.text)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

