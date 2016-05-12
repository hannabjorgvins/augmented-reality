import UIKit
import AVFoundation
import CoreMotion

protocol CameraDelegate {
    func receiveFrame(frame: UIImage)
}

class CameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureSession
    var output: AVCaptureVideoDataOutput!
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!
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
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        // create and add a previewlayer for the video captured (to be displayed on screen)
        let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        captureVideoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        captureVideoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        return captureVideoPreviewLayer
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
        let tempImage: CGImageRef = context.createCGImage(ciImage, fromRect: ciImage.extent)
        let image = UIImage(CGImage: tempImage)
        return image
    }
    
}