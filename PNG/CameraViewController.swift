//
//  CameraViewController.swift
//  PNG
//
//  Created by Sandeep Sahani on 18/07/23.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        toggleTorch(on: true)
        capturePhoto()
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession,
              let backCamera = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
            
            photoOutput = AVCapturePhotoOutput()
            captureSession.addOutput(photoOutput!)
            
            captureSession.startRunning()
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            setAutoWhiteBalance()
            setAutoFocusMode()
        } catch {
            print("Error setting up capture session: \(error.localizedDescription)")
        }
    }
    
    func setAutoWhiteBalance() {
        if let device = AVCaptureDevice.default(for: .video) {
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                do {
                    try device.lockForConfiguration()
                    device.whiteBalanceMode = .continuousAutoWhiteBalance
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting white balance: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func setAutoFocusMode() {
        if let device = AVCaptureDevice.default(for: .video) {
            if device.isFocusModeSupported(.continuousAutoFocus) {
                do {
                    try device.lockForConfiguration()
                    device.focusMode = .continuousAutoFocus
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting focus mode: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Defalut number of photos clicked 2 and default time 1 second.
    func capturePhoto(noOfPhotos: Int = 2, timeInterval: Double = 1.0) {
        // let photoSettings = AVCapturePhotoSettings()
        // photoSettings.flashMode = .auto
        var timer = Timer()
        var totalPhotos: Int = noOfPhotos
        var isRepeat = true
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: isRepeat) {_ in
            // Code to be executed after 10 ms (0.01 seconds)
            let photoSettings = self.getSettings(camera: backCamera)
            self.photoOutput?.capturePhoto(with: photoSettings, delegate: self)
            totalPhotos=totalPhotos-1
            if totalPhotos == 0 {
                isRepeat = false
                timer.invalidate()
            }
        }
        
    }
    
    func saveImageToGallery(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                print("Photo library access denied.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { [weak self] success, error in
                if let error = error {
                    print("Error saving image to gallery: \(error.localizedDescription)")
                } else {
                    print("Image saved to gallery.")
                }
                
                DispatchQueue.main.async {
                    // Perform any UI updates or display relevant messages here
                }
            }
        }
    }
    
    func getSettings(camera: AVCaptureDevice) -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()

//        if camera.hasFlash {
//            switch flashMode {
//               case .auto: settings.flashMode = .auto
//               case .on: settings.flashMode = .on
//               default: settings.flashMode = .off
//            }
//        }
        settings.flashMode = .auto
        return settings
    }
}

extension CameraViewController {
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        // Save the captured image to the photo gallery
        saveImageToGallery(image)
    }
}



extension CameraViewController {
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        // Add the capture button
//        let captureButton = UIButton(type: .system)
//        captureButton.setTitle("Capture", for: .normal)
//        captureButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//        captureButton.setTitleColor(.white, for: .normal)
//        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
//        captureButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(captureButton)
//
//        NSLayoutConstraint.activate([
//            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
//        ])
//    }
//
//    @objc func captureButtonTapped() {
//
//        capturePhoto()
//    }
}

