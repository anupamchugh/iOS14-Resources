//
//  ViewController.swift
//  CreateMLVideoStyleTransfer
//
//  Created by Anupam Chugh on 20/08/20.
//  Copyright © 2020 Anupam Chugh. All rights reserved.
//

//import UIKit
//import AVFoundation
//import Vision



import UIKit
import AVFoundation
import CoreMedia
import Vision
import VideoToolbox


enum Styles : String, CaseIterable{
    case starryBlue
    case strong
}

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate
{
    let parentStack = UIStackView()
    let imageView = UIImageView()
    let modelConfigControl = UISegmentedControl(items: ["Off","CPU", "GPU", "Neural Engine"])
    let styleTransferControl = UISegmentedControl(items: [Styles.starryBlue.rawValue,Styles.strong.rawValue])

    var currentModelConfig = 0
    var currentStyle = Styles.starryBlue

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupUI()
        configureSession()
        
    }
    
    func setupUI(){
        view.addSubview(parentStack)
        parentStack.axis = NSLayoutConstraint.Axis.vertical
        parentStack.distribution = UIStackView.Distribution.fill
        
        parentStack.addArrangedSubview(styleTransferControl)
        parentStack.addArrangedSubview(imageView)
        parentStack.addArrangedSubview(modelConfigControl)
        
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        modelConfigControl.selectedSegmentIndex = 0
        styleTransferControl.selectedSegmentIndex = 0
        
        modelConfigControl.addTarget(self, action: #selector(modelConfigChanged(_:)), for: .valueChanged)
        styleTransferControl.addTarget(self, action: #selector(styleTransferChanged(_:)), for: .valueChanged)
    }
    
    @objc func modelConfigChanged(_ sender: UISegmentedControl) {
        currentModelConfig = sender.selectedSegmentIndex
    }
    
    @objc func styleTransferChanged(_ sender: UISegmentedControl) {
        currentStyle = Styles.allCases[sender.selectedSegmentIndex]
    }
    
    
    func configureSession(){
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.medium

        // search for available capture devices
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices

        do {
            if let captureDevice = availableDevices.first {
                captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
            }
        } catch {
            print(error.localizedDescription)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput){
            captureSession.addOutput(videoOutput)
        }
        
        guard let connection = videoOutput.connection(with: .video) else { return }
        guard connection.isVideoOrientationSupported else { return }

        connection.videoOrientation = .portrait
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        if currentModelConfig == 0{
            DispatchQueue.main.async(execute: {
                self.imageView.image = CameraUtil.imageFromSampleBuffer(buffer: sampleBuffer)
            })
        }
        else{
                        
            let config = MLModelConfiguration()
            switch currentModelConfig {
            case 1:
                config.computeUnits = .cpuOnly
            case 2:
                config.computeUnits = .cpuAndGPU
            default:
                config.computeUnits = .all
            }
            
            var s : MLModel?
            
            switch currentStyle {
            case .starryBlue:
                s = try? StyleBlue.init(configuration: config).model
            case .strong:
                s = try? BlueStrong.init(configuration: config).model
            }
            
            guard let styleModel = s else{return}

            guard let model = try? VNCoreMLModel(for: styleModel) else { return }
            let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
                guard let results = finishedRequest.results as? [VNPixelBufferObservation] else { return }

                guard let observation = results.first else { return }

                DispatchQueue.main.async(execute: {
                    self.imageView.image = UIImage(pixelBuffer: observation.pixelBuffer)
                })
            }
            
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        }
    }
    
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
        
        let topMargin = topLayoutGuide.length
        parentStack.frame = CGRect(x: 0, y: topMargin, width: view.frame.width, height: view.frame.height - topMargin).insetBy(dx: 5, dy: 5)

//        if let connection =  self.previewLayer?.connection  {
//
//            let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.portrait
//            let previewLayerConnection : AVCaptureConnection = connection
//
//            if previewLayerConnection.isVideoOrientationSupported {
//
//                switch (orientation) {
//                case .portrait: updatePreviewLayer(for: previewLayerConnection, to: .portrait)
//                case .landscapeRight: updatePreviewLayer(for: previewLayerConnection, to: .landscapeRight)
//                case .landscapeLeft: updatePreviewLayer(for: previewLayerConnection, to: .landscapeLeft)
//                case .portraitUpsideDown: updatePreviewLayer(for: previewLayerConnection, to: .portraitUpsideDown)
//                default: updatePreviewLayer(for: previewLayerConnection, to: .portrait)
//
//                }
//            }
//        }
    }

//    private func updatePreviewLayer(for connection: AVCaptureConnection, to orientation: AVCaptureVideoOrientation) {
//        if connection.isVideoOrientationSupported {
//            connection.videoOrientation = orientation
//        }
//        previewLayer.frame = view.bounds
//    }
}

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}

class CameraUtil {
    class func imageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage {
        let pixelBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(buffer)!
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let imageRect: CGRect = CGRect(x: 0, y: 0, width: pixelBufferWidth, height: pixelBufferHeight)
        let ciContext = CIContext.init()
        let cgimage = ciContext.createCGImage(ciImage, from: imageRect )
        
        let image = UIImage(cgImage: cgimage!)
        return image
    }
}
