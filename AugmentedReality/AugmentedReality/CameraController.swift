import UIKit
import AVFoundation
import CoreMotion

protocol CameraDelegate {
    func receiveFrame(frame: UIImage)
}

class CameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureSession
    var output: AVCaptureVideoDataOutput!
    var cameraDelegate : CameraDelegate?
    
    override init() {
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        super.init()
        
        setUpCamera()
    }
    
    func setUpCamera() {
        // create an input from the back-camera of the iPhone, and add to the session
        let devices = AVCaptureDevice.devices() as! [AVCaptureDevice]
        for device in devices {
            if device.position == AVCaptureDevicePosition.Back && device.hasMediaType(AVMediaTypeVideo) {
                do {
                    do {
                        try device.lockForConfiguration()
                        device.focusMode = .Locked
                        device.unlockForConfiguration()
                    } catch let error as NSError {
                        print(error)
                    }
                    
                    let inputDevice = try AVCaptureDeviceInput(device: device)
                    if self.session.canAddInput(inputDevice) {
                        self.session.addInput(inputDevice)
                        break;
                    } else {
                        print("Could not add input device")
                    }
                } catch {
                    print("Could not create inputdevice")
                }
            }
        }
        
        // create and add output in the form of still images
        self.output = AVCaptureVideoDataOutput()
        
        if self.session.canAddOutput(self.output) {
            let dispatch_queue : dispatch_queue_t = dispatch_queue_create("streamoutput", DISPATCH_QUEUE_SERIAL)
            self.output.setSampleBufferDelegate(self, queue: dispatch_queue)
            self.session.addOutput(self.output)
            let connection = output.connectionWithMediaType(AVFoundation.AVMediaTypeVideo)
            connection.videoOrientation = .Portrait
        } else {
            print("Could not add output device")
        }
        
    }
    
    func startCapturing() {
        // start session
        self.session.startRunning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let currentFrame : UIImage = self.convertImageFromCMSampleBufferRef(sampleBuffer!)
        self.cameraDelegate?.receiveFrame(currentFrame)
    }
    
    func convertImageFromCMSampleBufferRef(sampleBuffer:CMSampleBuffer) -> UIImage {
        let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciImage : CIImage = CIImage(CVPixelBuffer: pixelBuffer)
        let context = CIContext(options:nil)
        
        let height = ciImage.extent.height
        let screenHeight = UIScreen.mainScreen().bounds.height
        let screenWidth = UIScreen.mainScreen().bounds.width
        let scaleFactor = height / screenHeight
        let largeImageSize = CGSize(width: screenWidth * scaleFactor, height: height)
        let rect = CGRect(origin: ciImage.extent.origin, size: largeImageSize)
        
        let tempImage: CGImageRef = context.createCGImage(ciImage, fromRect: rect)
        let image = UIImage(CGImage: tempImage)
        return image
    }
    
}