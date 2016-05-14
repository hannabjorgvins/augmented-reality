
import SceneKit

class ViewController: UIViewController, CameraDelegate, UIGestureRecognizerDelegate {
    
    var cameraController : CameraController = CameraController()
    var scnView = SCNView()
    var modelView = ModelView()
    var currentFrame : UIImage?

    func receiveFrame(frame: UIImage) {
        self.currentFrame = frame
        let transformation = OpenCVWrapper.getTransformationMatrixBetweenObjectPointsAndImage(frame) as! [Double]
        if transformation.count != 0 {
            modelView.setCameraTransformationMatrixTo(transformation)
            modelView.showObject()
            scnView.playing = true
        } else {
            modelView.hideObject()
        }
        modelView.background.contents = frame

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView.frame = self.view.bounds
        scnView.backgroundColor = UIColor.clearColor()
        scnView.autoenablesDefaultLighting = true
        scnView.scene = modelView
        
        readCalibrationParameters()
        cameraController.cameraDelegate = self

        self.view.addSubview(scnView)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("saveCurrentFrame:"))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        cameraController.startCapturing()
    }
    
    func readCalibrationParameters() {
        var cameraMatrix : [Double] = []
        var distortionMatrix : [Double] = []
        
        if let path = NSBundle.mainBundle().pathForResource("CalibrationParams", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                do {
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    if let dict = jsonResult as? [String: AnyObject] {
                        if let cameraValues = dict["CameraMatrix"] as? [AnyObject] {
                            for value in cameraValues {
                                cameraMatrix.append(value as! Double)
                            }
                        }
                        print(cameraMatrix)
                        if let distortionValues = dict["Distortion"] as? [AnyObject] {
                            for value in distortionValues {
                                distortionMatrix.append(value as! Double)
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
        
        OpenCVWrapper.setCameraMatrix(cameraMatrix)
        OpenCVWrapper.setDistortionCoefficients(distortionMatrix)
        OpenCVWrapper.setObjectPoints([1.0, 1.0, -1.0, -1.0,
                                       -1.0, -1.0, -1.0, -1.0,
                                       -1.0, 1.0, 1.0, -1.0])
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

    override func shouldAutorotate() -> Bool {
        return false
    }
}

