//
//  HifiLinkingPageController.swift
//  metaMe
//
//  Created by 최유라 on 2017. 5. 11..
//  Copyright © 2017년 최유라. All rights reserved.
//


import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity

class HifiPageController: WKInterfaceController, WCSessionDelegate  {
    
    @IBOutlet var stagePic: WKInterfaceImage!
    
    @IBOutlet var stageLabel: WKInterfaceLabel!
    
    @IBOutlet var loadingBarGroup: WKInterfaceGroup!
    
    @IBOutlet var taskPic: WKInterfaceImage!
    
    @IBOutlet var taskGroup: WKInterfaceGroup!
    
    @IBOutlet var valueLabel: WKInterfaceLabel!
    @IBOutlet var loadingBarProgress: WKInterfaceImage!
    
    @IBOutlet var volumeLable: WKInterfaceLabel!
    var loadingBarWidth = 0.0;
    
    var data = String()
    
    weak var timer: Timer?
    
    let motionManager = CMMotionManager()
    
    var volume = 75.0
    var roll = 0.0
    var pitch = 0.0
    var pitch_1 = 0.0
    var pitch_2 = 0.0
    var roll_start = 0.0
    
    var oldValue = 0.0
    var differ = 0.0
    
    var nowTime = 0.0
    var oldTime = 0.0
    var checkTime = 0.0
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true)
        {[weak self] _ in
            if(self?.loadingBarWidth == 168) {
                self?.stopTimer()
                self?.stagePic.setImageNamed("controlling")
                
                /*if(self?.data.lowercased() == "hi-fi"){
                 self?.stageLabel.setText("Controlling")
                 self?.startPlay()
                 }*/
                
                if((self?.data.lowercased().range(of: "hi")) != nil) || ((self?.data.lowercased().range(of: "music")) != nil) || ((self?.data.lowercased().range(of: "sound")) != nil) || ((self?.data.lowercased().range(of: "volume")) != nil) || ((self?.data.lowercased().range(of: "stereo")) != nil){
                    self?.stageLabel.setText("Music")
                    self?.taskGroup.setBackgroundImageNamed("black")
                    self?.startPlay()
                }
                
                if ((self?.data.lowercased().range(of: "li")) != nil) {
                    self?.stageLabel.setText("Light")
                    self?.taskGroup.setBackgroundImageNamed("black")
                    self?.startLight()
                }
                
                /* if(self?.data.lowercased() == "light"){
                 self?.stageLabel.setText("light")
                 self?.startLight()
                 
                 }
                 */
                self?.loadingBarGroup.setHidden(true)
                self?.volumeLable.setHidden(false)
                self?.gesture ()
                
            } else {
                self?.loadingBarWidth += 1;
                self?.loadingBarProgress.setWidth(CGFloat((self?.loadingBarWidth)!))
            }
        }
        
    }
    
    
    func stopTimer () {
        timer?.invalidate()
    }
    
    deinit {
        stopTimer()
    }
    
    
    func gesture () {
        var i = 0
        var volume_start = 50.0 //ATTENTION: needs to be read from hardware in final implementation
        var volume_vib = volume_start
        var volume_old = 0.0
        let scale = 0.5
        motionManager.accelerometerUpdateInterval = 0.1;
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if i == 0 {
                self.roll_start = atan2(-(data?.acceleration.y)!, (data?.acceleration.z)!) * 57.3
                if self.roll_start < 0 {
                    self.roll_start = (180.0 - abs(self.roll_start)) * -1.0
                } else if self.roll_start >= 0 {
                    self.roll_start = 180.0 - abs(self.roll_start)
                }
                WKInterfaceDevice.current().play(.start)
            }
            
            self.roll = atan2(-(data?.acceleration.y)!, (data?.acceleration.z)!) * 57.3
            self.pitch_2 = self.pitch_1
            self.pitch_1 = self.pitch
            self.pitch = atan2(-(data?.acceleration.x)!, (data?.acceleration.z)!) * 57.3
            if self.roll < 0 {
                self.roll = (180.0 - abs(self.roll)) * -1
            } else if self.roll >= 0 {
                self.roll = 180.0 - abs(self.roll)
            }
            
            self.volume = (volume_start) + (self.roll - self.roll_start)*scale
            
            //print(abs(volume_vib - self.volume))
            if abs(volume_vib - self.volume) > 50*scale {
                self.volume = volume_old
                volume_start = self.volume
                self.roll_start = self.roll
                WKInterfaceDevice.current().play(.retry)
                volume_vib = self.volume
            } else if abs(volume_vib - self.volume) > 5*scale {
                volume_old = self.volume
                WKInterfaceDevice.current().play(.click)
                volume_vib = self.volume
            }
            
            if (self.volume) > 100 {
                self.volume = 100
                WKInterfaceDevice.current().play(.failure)
            } else if (self.volume) < 0 {
                self.volume = 0
                WKInterfaceDevice.current().play(.failure)
            }
            
            self.valueLabel.setText(String(describing: Int(self.volume)))
            
            
            
            self.volumeLable.setText(String(describing: round(self.volume)))
            //self.volumeLable.setText(String(describing: Float(self.volume)/100))
            
            /*  if(self.data.lowercased() == "hi-fi"){
             self.volumeChange(value: Float(self.volume)/100)
             }*/
            
            if((self.data.lowercased().range(of: "hi")) != nil) || ((self.data.lowercased().range(of: "music")) != nil) || ((self.data.lowercased().range(of: "sound")) != nil) || ((self.data.lowercased().range(of: "volume")) != nil) || ((self.data.lowercased().range(of: "stereo")) != nil){
                self.volumeChange(value: Float(self.volume)/100)
            }
            
            if ((self.data.lowercased().range(of: "li")) != nil) {
                self.lightChange(value: Float(self.volume)/100)
            }
            
            /* if(self.data.lowercased() == "light"){
             self.lightChange(value: Float(self.volume)/100)
             }*/
            
            
            self.nowTime = CFAbsoluteTimeGetCurrent()
            
            self.differ = self.oldValue - self.volume
            
            if (abs(self.differ) < 5.0*scale) {
                //print("stop")
                print(self.pitch, self.roll)
                self.checkTime += self.nowTime - self.oldTime
                //print(self.checkTime)
                //if ( self.checkTime > 3.0) || abs(Double((data?.acceleration.x)!)) > 0.8 {
                //if ( self.checkTime > 5.0) {
                //if abs(Double((data?.acceleration.x)!)) > 0.85 {
                //if self.pitch < 0.0 && self.pitch > -120.0 && self.pitch_1 < 0.0 && self.pitch_1 > -120.0 && self.pitch_2 < 0.0 && self.pitch_2 > -120.0 {
                if (self.checkTime > 5.0) || (self.pitch < -85.0 && self.pitch > -110.0 && self.pitch_1 < -85.0 && self.pitch_1 > -110.0 && self.pitch_2 < -85.0 && self.pitch_2 > -110.0 && (self.roll > 120.0 || self.roll < 80) ) {
                    //    print(self.checkTime)
                    self.motionManager.stopAccelerometerUpdates()
                    WKInterfaceDevice.current().play(.success)
                    self.stagePic.setImageNamed("leaving")
                    self.stageLabel.setText("Leaving")
                    //self.taskPic.setImageNamed("tick")
                    self.taskGroup.setBackgroundImageNamed("tick")
                    self.valueLabel.setText("")
                }
                
            }
            else {
                //   print("moving")
                // print(self.differ)
                self.checkTime = 0.0
            }
            self.oldValue = self.volume
            self.oldTime = self.nowTime;
            //print(self.roll_start+180.0, self.roll+180.0, round(self.volume))
            if i < 2 {
                i += 1
            }
        }
        
    }
    
    func startPlay() {
        if WCSession.default().isReachable == true {
            
            let requestValues = ["command" : "start"]
            let session = WCSession.default()
            session.sendMessage(requestValues, replyHandler: nil, errorHandler: { error in
                print("error: \(error)")
            })
        }
    }
    
    func stopPlay() {
        if WCSession.default().isReachable == true {
            
            let requestValues = ["command" : "stop"]
            let session = WCSession.default()
            
            session.sendMessage(requestValues as! [String : AnyObject], replyHandler: { reply in
                self.stageLabel.setText(reply["status"] as? String)
            }, errorHandler: { error in
                print("error: \(error)")
            })
        }
    }
    
    func volumeChange(value: Float) {
        let requestValues = ["command" : "volume", "level" : value] as [String : Any]
        let session = WCSession.default()
        
        session.sendMessage(requestValues as [String : AnyObject],
                            replyHandler: nil, errorHandler: { error in
                                print("error: \(error)")
        })
        // print(value)
    }
    
    func startLight() {
        if WCSession.default().isReachable == true {
            
            let requestValues = ["command" : "startLight"]
            let session = WCSession.default()
            session.sendMessage(requestValues, replyHandler: nil, errorHandler: { error in
                print("error: \(error)")
            })
        }
        
        
    }
    
    func lightChange(value: Float) {
        let requestValues = ["command" : "light", "level" : value] as [String : Any]
        let session = WCSession.default()
        
        session.sendMessage(requestValues as [String : AnyObject],
                            replyHandler: nil, errorHandler: { error in
                                print("error: \(error)")
        })
        // print(value)
    }
    
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        let copy = context as AnyObject;
        print(copy.value(forKey: "data") ?? "no data");
        self.data = (copy.value(forKey: "data") as? String)!// ?? "no data"
        
        print(data);
        /* if (self.data.lowercased() == "light"){
         self.taskPic.setImageNamed("light")
         } else if (self.data.lowercased() == "hi-fi") {
         self.taskPic.setImageNamed("hi-fi")
         } else if (self.data.lowercased() == "aircon") {
         self.taskPic.setImageNamed("aircon")
         }*/
        
        if ((self.data.lowercased().range(of: "li")) != nil) {
            //self.taskPic.setImageNamed("light")
            self.taskGroup.setBackgroundImageNamed("light")
        }   else if((self.data.lowercased().range(of: "hi")) != nil) || ((self.data.lowercased().range(of: "music")) != nil) || ((self.data.lowercased().range(of: "sound")) != nil) || ((self.data.lowercased().range(of: "volume")) != nil) || ((self.data.lowercased().range(of: "stereo")) != nil){
            //self.taskPic.setImageNamed("hi-fi")
            self.taskGroup.setBackgroundImageNamed("hi-fi")
        } else if ((self.data.lowercased().range(of:"air")) != nil) {
            //self.taskPic.setImageNamed("aircon")
            self.taskGroup.setBackgroundImageNamed("aircon")
        }
        
        WKInterfaceDevice.current().play(.failure)
        startTimer();
        
        
        
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        didDeactivate()
        
    }
    
    
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
}
