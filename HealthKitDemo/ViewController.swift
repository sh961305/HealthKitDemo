//
//  ViewController.swift
//  HealthKitDemo
//
//  Created by zcon on 2019/2/26.
//  Copyright © 2019 zcon. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    lazy var manager = StepCountManager.shared
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if StepCountManager.isAvailable()
        {
            manager.requestAuthorization { (success, error) in
                
                if success
                {
                    self.manager.getTodayTotalCount { (count) in
                        
                    }
                }
            }
        }
    }
}

