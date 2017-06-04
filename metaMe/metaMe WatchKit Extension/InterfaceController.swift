//
//  InterfaceController.swift
//  metaMe WatchKit Extension
//
//  Created by 최유라 on 2017. 4. 27..
//  Copyright © 2017년 최유라. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion


class InterfaceController: WKInterfaceController {
    @IBOutlet var button: WKInterfaceButton!
    @IBAction func buttonPressed() {
        presentTextInputController(withSuggestions: nil,
                                   allowedInputMode: .plain)
        {(input)->Void in
            print("input: \(input)")
            let task = input?[0] as? String
            print("task: \(task)")
            
            self.presentController(withName: "metaPage", context: [
                "segue": "pagebased",
                "data": task
                ]);
        }
        
    }
 
    func raiseWrist() {
        var loop = 1
        let motionManager = CMMotionManager()
        
        motionManager.accelerometerUpdateInterval = 0.1;
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if loop == 1 {
                if Double((data?.acceleration.y)!) < 0.4 {
                    
                    self.presentTextInputController(withSuggestions: nil,
                                                    allowedInputMode: .plain)
                    {(input)->Void in
                        print("input: \(input)")
                        let task = input?[0] as? String
                        print("task: \(task)")
                        
                        self.presentController(withName: "metaPage", context: [
                            "segue": "pagebased",
                            "data": task
                            ]);
                    }
                    
                    loop = 0
                }
            }
        }
    }
    
}




func awake(withContext context: Any?) {
    awake(withContext: context)
    
    // Configure interface objects here.
}

func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    willActivate()
}

func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    didDeactivate()
    
}


