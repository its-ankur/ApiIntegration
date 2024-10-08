import AVFoundation
import UIKit

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var qrCodeView: UIView!  // Camera preview area
    @IBOutlet weak var Result: UILabel!     // Label to display the scanned QR code
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var scannedResult: String?
    var currentZoomFactor: CGFloat = 1.0  // Track the current zoom factor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar for this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Hide the back button
        //self.navigationItem.hidesBackButton = true
        
        // Setup camera session
        setupCamera()
        
        // Add pinch gesture recognizer for zooming
                let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
                qrCodeView.addGestureRecognizer(pinchGesture)

        
        // Add swipe gesture recognizer for left swipe
        addSwipeGesture()
    }
    
    // MARK: - Pinch Gesture Handler
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            if gesture.state == .began || gesture.state == .changed {
                do {
                    try device.lockForConfiguration()
                    
                    // Calculate the new zoom factor
                    let newZoomFactor = max(1.0, min(currentZoomFactor * gesture.scale, device.activeFormat.videoMaxZoomFactor))
                    
                    // Set the new zoom factor
                    device.videoZoomFactor = newZoomFactor
                    
                    // Unlock the device configuration
                    device.unlockForConfiguration()
                    
                    // Update the current zoom factor
                    currentZoomFactor = newZoomFactor
                    
                    // Reset the gesture scale for the next change
                    gesture.scale = 1.0
                } catch {
                    print("Error locking configuration: \(error)")
                }
            }
        }

    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Change the back button color to orange
            self.navigationController?.navigationBar.tintColor = UIColor.orange
        }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        // Update previewLayer to fit qrCodeView
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = qrCodeView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        qrCodeView.layer.addSublayer(previewLayer)
        
        // Start capture session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    private func addSwipeGesture() {
        // Swipe left gesture
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .right
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            // Go back to the previous screen
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - QR Code Scanning
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            displayResult(result: stringValue)
        }
    }
    
    func displayResult(result: String) {
        // Update the Result label with the scanned QR code value
        Result.text = "Scanned Result: " + result
        scannedResult = result
        
        // Optionally, show an alert if needed
        let alert = UIAlertController(title: "QR Code Scanned", message: result, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.captureSession.startRunning()  // Resume scanning after alert dismissed
        })
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession.isRunning) {
            captureSession.stopRunning()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        guard let resultToShare = scannedResult else {
            let alert = UIAlertController(title: "No Result", message: "Please scan a QR code first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [resultToShare], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToFlickr]
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func flashButton(_ sender: UIButton) {
        
        // Bring the button to the front
            self.view.bringSubviewToFront(sender)
        
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
                return // Device doesn't have a torch (flashlight)
            }
            
            do {
                try device.lockForConfiguration() // Lock the device for configuration
                device.torchMode = (device.torchMode == .on) ? .off : .on // Toggle the torch mode
                sender.setTitle(device.torchMode == .on ? "Flash Off" : "Flash On", for: .normal) // Update button title
                device.unlockForConfiguration() // Unlock the device configuration
            } catch {
                print("Error toggling flashlight: \(error)")
            }
    }
    
}

