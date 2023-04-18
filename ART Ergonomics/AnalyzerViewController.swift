//
//  AnalyzerViewController.swift
//  ART Ergonomics
//
//  Created by Hari Iyer on 4/16/23.
//

import UIKit
import PhotosUI
import AVFoundation
import TensorFlowLite
import Vision
import Charts

class AnalyzerViewController: UIViewController, PHPickerViewControllerDelegate {
    
    var selectedVideos: [URL] = []
    private let videoPlayer = AVPlayer()
    private let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
    ])
    private var modelInterpreter: Interpreter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load the TensorFlow Lite model
        guard let modelPath = Bundle.main.path(forResource: "posenet_mobilenet_v1_100_257x257_multi_kpt_stripped", ofType: "tflite") else {
            print("Failed to load the model file.")
            return
        }
        do {
            let modelData = try Data(contentsOf: URL(fileURLWithPath: modelPath))
            modelInterpreter = try Interpreter(modelData: modelData)
        } catch {
            print("Failed to create the interpreter.")
            return
        }
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 0 // set to 0 for unlimited selection
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        for result in results {
            let itemProvider = result.itemProvider
            itemProvider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { item, error in
                if let url = item as? URL {
                    print(url)
                }
            }
        }
    }
}
