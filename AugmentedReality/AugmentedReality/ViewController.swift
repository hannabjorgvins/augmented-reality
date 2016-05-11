
import SceneKit

class ViewController: UIViewController, CameraDelegate, UIGestureRecognizerDelegate {
    
    var cameraController : CameraController = CameraController()
    var scnView : SCNView = SCNView()
    var currentFrame : UIImage?

    func receiveFrame(frame: UIImage) {
        self.currentFrame = frame
        //scnView.scene?.background.contents = frame
        // do some cool stuff with the image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let modelView = ModelView()
        //scnView = self.view as! SCNView
        scnView.frame = self.view.frame
        scnView.backgroundColor = UIColor.clearColor()
        scnView.scene = modelView
        
        readCalibrationParameters()
        
        cameraController.cameraDelegate = self
        let previewLayer = cameraController.getPreviewLayer()
        previewLayer.frame = self.view.frame
        self.view.layer.addSublayer(previewLayer)
        self.view.addSubview(scnView)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("saveCurrentFrame:"))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        cameraController.startCapturing()
    }
    
    func readCalibrationParameters() {
        var cameraMatrix : [Float32] = []
        var distortionMatrix : [Float32] = []
        
        if let path = NSBundle.mainBundle().pathForResource("CalibrationParams", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                do {
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    if let dict = jsonResult as? [String: AnyObject] {
                        if let cameraValues = dict["CameraMatrix"] as? [AnyObject] {
                            for value in cameraValues {
                                cameraMatrix.append(value as! Float32)
                            }
                        }
                        print(cameraMatrix)
                        if let distortionValues = dict["Distortion"] as? [AnyObject] {
                            for value in distortionValues {
                                distortionMatrix.append(value as! Float32)
                            }
                        }
                        print(distortionMatrix)
                    } else {
                        print("Failed to parse JSON file")
                    }
                } catch let error as NSError {
                    print("Failed to unarchive JSON file")
                    print(error)
                }
            } catch let error as NSError {
                print("Cannot load JSON file")
                print(error)
            }
        } else {
            print("Cannot find path")
        }
    }

    func saveCurrentFrame(sender: UITapGestureRecognizer) {
        if let image = self.currentFrame {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

