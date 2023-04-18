//
//  RecorderViewController.swift
//  ART Ergonomics
//
//  Created by Hari Iyer on 4/16/23.
//
import UIKit
import AVFoundation

class RecorderViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var movieOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // Set up the video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("Failed to add video input")
            }
        } catch {
            print("Error setting up video input: \(error.localizedDescription)")
        }
        
        // Set up the audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
        
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            } else {
                print("Failed to add audio input")
            }
        } catch {
            print("Error setting up audio input: \(error.localizedDescription)")
        }
        
        // Set up the movie output
        movieOutput = AVCaptureMovieFileOutput()
        
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        } else {
            print("Failed to add movie output")
        }
        
        // Set up the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Set up the record button
        recordButton = UIButton(type: .custom)
        recordButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        recordButton.center = CGPoint(x: view.bounds.midX, y: view.bounds.maxY - 100)
        recordButton.layer.cornerRadius = 40
        recordButton.layer.borderWidth = 2
        recordButton.layer.borderColor = UIColor.white.cgColor
        recordButton.backgroundColor = UIColor.red
        recordButton.addTarget(self, action: #selector(recordButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    @objc func recordButtonPressed(_ sender: UIButton) {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            recordButton.backgroundColor = UIColor.red
        } else {
            let currentDate = Date()

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .full

            let dateString = dateFormatter.string(from: currentDate)
            let randomInt = Int(arc4random_uniform(10000000))
            let fileURL = getDocumentsDirectory().appendingPathComponent(String(randomInt) + ".mp4")
            movieOutput.startRecording(to: fileURL, recordingDelegate: self)
            recordButton.backgroundColor = UIColor.green
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

extension RecorderViewController: AVCaptureFileOutputRecordingDelegate {
    internal func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
                    print("Started recording to \(fileURL)")
                }
                
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
                    if error == nil {
                        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
                    } else {
                        print("Error recording video: \(error!.localizedDescription)")
                    }
                }
                
                @objc func video(_ videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
                    if error == nil {
                        print("Video saved successfully!")
                    } else {
                        print("Error saving video: \(error!.localizedDescription)")
                    }
                }
            }
