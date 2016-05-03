import UIKit
import AVFoundation
import CoreMotion

class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureSession
    var output: AVCaptureVideoDataOutput!
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!
    var imageView : UIImageView
    var currentFrame : UIImage?
    
    init() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        imageView = UIImageView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(imageView)
        
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
        
        // create and add a previewlayer for the video captured (to be displayed on screen)
        //captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        //captureVideoPreviewLayer!.frame = self.view.frame
        //captureVideoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        //captureVideoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        //self.view.layer.addSublayer(captureVideoPreviewLayer)
        
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
        
        // start session
        self.session.startRunning()

    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let image : UIImage = self.convertImageFromCMSampleBufferRef(sampleBuffer!)
            dispatch_async(dispatch_get_main_queue(), {
                self.currentFrame = image
                let iv = UIImageView(image: image)
                iv.frame = self.view.frame
                self.view.addSubview(iv)
                self.imageView.image = self.currentFrame
                for view in self.view.subviews {
                    view.removeFromSuperview()
                }
                self.view.addSubview(iv)
            })
        }
    }
    
    func convertImageFromCMSampleBufferRef(sampleBuffer:CMSampleBuffer) -> UIImage {
        let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciImage : CIImage = CIImage(CVPixelBuffer: pixelBuffer)
        let context = CIContext(options:nil);
        let tempImage: CGImageRef = context.createCGImage(ciImage, fromRect: ciImage.extent)
        let image = UIImage(CGImage: tempImage)
        return image
    }
}