//
//  ViewController.swift
//  Books Generator
//
//  Created by Mostafa Sami on 12/4/16.
//  Copyright © 2016 Sami. All rights reserved.
//

import UIKit
import Alamofire

class MainViewController: UIViewController {
    
    static let BASE_URL = "http://quiet-shelf-83733.herokuapp.com"
    static let WELCOME_URL = "/welcome"
    static let CHAT_URL = "/chat"

    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(MainViewController.BASE_URL + MainViewController.WELCOME_URL).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

