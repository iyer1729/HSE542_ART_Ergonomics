//
//  CameraViewController.swift
//  ART Ergonomics
//
//  Created by Hari Iyer on 4/15/23.
//

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession: AVCaptureSession!
    var request: VNRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1280x720
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        // Set up the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        // Set up the pose detection request
        request = VNDetectHumanBodyPoseRequest(completionHandler: handlePoseDetection)
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
    
    // AVCaptureVideoDataOutputSampleBufferDelegate method
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Run the pose detection request
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func handlePoseDetection(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        // Process the pose detection results
        for observation in observations {
            // Get the pose points
            let recognizedPoints = try? observation.recognizedPoints(forGroupKey: .all)
            guard let points = recognizedPoints else { continue }
            print(points)
            // Draw the pose points on the preview layer
            DispatchQueue.main.async {
                self.previewLayer.sublayers?.removeSubrange(1...)
                for (_, point) in points {
                    let circleLayer = CAShapeLayer()
                    let center = CGPoint(x:point.y * self.view.bounds.width , y: point.x * self.view.bounds.height)
                    let radius: CGFloat = 5

                    circleLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true).cgPath
                    circleLayer.fillColor = UIColor.red.cgColor
                    self.previewLayer.addSublayer(circleLayer)
                }
            }
        }
    }
}
