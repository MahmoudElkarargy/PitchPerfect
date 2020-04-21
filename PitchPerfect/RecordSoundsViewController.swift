//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Mahmoud Elkarargy on 4/19/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!

    enum RecordingState {
        case  recording
        case notRecording
    }

    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }

    func  configureUI(_ recordingState: RecordingState) {
        switch recordingState {
        case .recording:
        // Update the UI to reflect recording state
            recordingLabel.text = "Recording in progress"
            stopRecordingButton.isEnabled = true
            recordButton.isEnabled = false
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
            let recordingName = "recordedVoice.wav"
            let pathArray = [dirPath, recordingName]
            let filePath = URL(string: pathArray.joined(separator: "/"))
            
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        case .notRecording:
            // Update the UI to reflect not recording state
            stopRecordingButton.isEnabled = false
            recordButton.isEnabled = true
            recordingLabel.text = "Tab to record"
            
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setActive(false)
        }
    }
    @IBAction func RecordAudio(_ sender: Any) {
        configureUI(.recording)
    }
    
    @IBAction func StopRecording(_ sender: Any) {
        configureUI(.notRecording)

    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }
        else {
            let controller = UIAlertController()
            controller.title = "Error"
            controller.message = "Please try agian"
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { action in self.dismiss(animated: true, completion: nil)
            }
            
            controller.addAction(okAction)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

