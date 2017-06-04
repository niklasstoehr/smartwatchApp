//
//  ViewController.swift
//  metaMe
//
//  Created by 최유라 on 2017. 4. 27..
//  Copyright © 2017년 최유라. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var volumeLable: UILabel!
      @IBOutlet weak var volumeControl: UISlider!

    @IBAction func playAudio(_ sender: Any) {
        startPlay()
    }
    
    @IBAction func stopAudio(_ sender: Any) {
        stopPlay()
    }
    
    @IBAction func sliderMoved(_ sender: Any) {
        adjustVolume(level: volumeControl.value)
    }

    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioPlayer: AVAudioPlayer?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
            
            if session.isPaired != true {
                print("Apple Watch is not paired")
            }
            
            if session.isWatchAppInstalled != true {
                print("WatchKit app is not installed")
            }
        } else {
            print("WatchConnectivity is not supported on this device")
        }
        
        var url: NSURL?
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            url = NSURL.fileURL(
                withPath: Bundle.main.path(forResource: "music",
                                                      ofType: "mp3")!) as NSURL
        } catch {
            print("AudioSession error")
        }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url! as URL,
                                            fileTypeHint: nil)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.5
            self.volumeLable.text = String(0.5)

        } catch let error as NSError {
            print("Error: \(error.description)")
        }
    }
    
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopPlay() {
        self.audioPlayer?.stop()
    }
    
    func startPlay() {
        self.audioPlayer?.play()
    }
    
    func adjustVolume(level: Float)
    {
        audioPlayer?.volume = level
        self.volumeLable.text = String(level)

    }
    
    func startLight() {
        UIScreen.main.brightness = 0.5
    }
    
    func adjustLight(level: Float)
    {
        UIScreen.main.brightness = CGFloat(level)

    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        print(message);
        if (message["command"] as! String == "start") {
            startPlay()
        } else if (message["command"] as! String  == "volume") {
            let volume = message["level"] as! Float;
            self.adjustVolume(level: volume)
             self.volumeLable.text = String(volume)
            self.volumeControl.setValue(volume, animated: true)
        } else if(message["command"] as! String == "startLight") {
            startLight()
        }else if (message["command"] as! String  == "light") {
            let volume = message["level"] as! Float;
            self.adjustLight(level: volume)
            self.volumeLable.text = String(volume)
            self.volumeControl.setValue(volume, animated: true)
        }
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}

