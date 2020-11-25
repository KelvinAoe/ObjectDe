//
//  ViewController.swift
//  ObjectD
//
//  Created by Kelvin Aoe on 01/05/20.
//  Copyright © 2020 Kelvin Aoe. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    override var prefersStatusBarHidden: Bool{
        return true
        
    }
    @IBOutlet weak var BelowView: UIView!
    @IBOutlet weak var objectname: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    
    var model = Resnet50().model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else{return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        view.addSubview(BelowView)
        
        BelowView.clipsToBounds = true
        BelowView.layer.cornerRadius = 15.0
        BelowView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
        
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let model = try? VNCoreMLModel(for: model) else {return}
        let request = VNCoreMLRequest(model: model){
            (finishedReq, err)in
            guard let results = finishedReq.results as? [VNClassificationObservation]else{return}
            guard let firstObeservation = results.first else{return}
            
            var name :String = firstObeservation.identifier
            var acc : Int = Int (firstObeservation.confidence * 100)
            
            
            DispatchQueue.main.async {
                self.objectname.text = name
                self.accuracyLabel.text = "Accuracy:\(acc)%"
            }
            
            
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    


}

