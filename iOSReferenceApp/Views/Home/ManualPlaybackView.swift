//
//  ManualPlaybackView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-09.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ManualPlaybackView: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var m3u8PathTextField: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func actionPlay(_ sender: UIButton) {
        if let path = m3u8PathTextField.text {
            play(path: path)
        }
    }
    
    @IBAction func actionPathUpdated(_ sender: UITextField) {
        togglePlayButton(enabled: isValid(field: sender))
    }
    
    fileprivate func play(path: String) {
        guard let url = URL(string: path) else {
            showMessage(title: "Invalid URL", message: "Please supply a valid m3u8 url")
            return
        }
        
        play(url: url)
    }
    
    fileprivate func play(url: URL) {
        let avPlayer = AVPlayer(url: url)
        let playController = AVPlayerViewController()
        playController.player = avPlayer
        
        self.present(playController, animated: true)
    }
    
    fileprivate func isValid(field: UITextField) -> Bool {
        guard let text = field.text else { return false }
        return !text.isEmpty
    }
}

// MARK: - Update UI
extension ManualPlaybackView {
    func togglePlayButton(enabled: Bool) {
        playButton.isEnabled = enabled
        playButton.backgroundColor = enabled ? UIColor.ericssonBlue : UIColor.lightGray
    }
}

// MARK: - Text Input Management
extension ManualPlaybackView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == m3u8PathTextField {
            if let path = textField.text {
                play(path: path)
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == m3u8PathTextField {
            togglePlayButton(enabled: isValid(field: m3u8PathTextField))
        }
    }
}
