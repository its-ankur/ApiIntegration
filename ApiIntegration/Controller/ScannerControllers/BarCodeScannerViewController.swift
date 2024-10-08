import AVFoundation
import UIKit

class BarCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var barCodeView: UIView!
    @IBOutlet weak var result: UILabel! // This will show the scanned result.
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var scannedResult: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar for this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Hide the back button
        self.navigationItem.hidesBackButton = true
        
        // Setup camera session
        setupCamera()
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
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce, .qr] // Include QR codes if needed.
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = barCodeView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        barCodeView.layer.addSublayer(previewLayer) // Corrected to add the layer to barCodeView
        
        // Start capture session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
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
        // Display the scanned result in the label
        self.result.text = "Scanned Result: " + result
        scannedResult = result  // Store the scanned result
        
        // Optionally, you can also show an alert
        let alert = UIAlertController(title: "Bar Code Scanned", message: result, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Resume scanning after alert dismissed
            self.captureSession.startRunning()
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
        print("Back button tapped") // Debugging statement
        // Instantiate a new MyVisitsController
        guard let myVisitsVC = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController else {
            print("MyVisitsController not found") // Debugging statement
            return
        }
        
        // Push the new MyVisitsController onto the navigation stack
        self.navigationController?.pushViewController(myVisitsVC, animated: true)
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        guard let resultToShare = scannedResult else {
            // Optionally, you can show an alert that there is no result to share
            let alert = UIAlertController(title: "No Result", message: "Please scan a Bar code first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Create the share activity
        let activityViewController = UIActivityViewController(activityItems: [resultToShare], applicationActivities: nil)
        
        // Exclude certain activity types if needed
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToFlickr]
        
        // Present the share sheet
        present(activityViewController, animated: true, completion: nil)

    }
    
    
}

