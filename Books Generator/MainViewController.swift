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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(Constants.BASE_URL + Constants.WELCOME_URL).responseJSON { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
        
    }

}

