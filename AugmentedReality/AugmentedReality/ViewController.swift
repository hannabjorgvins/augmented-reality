
import SceneKit

class ViewController: UIViewController, CameraDelegate, UIGestureRecognizerDelegate {
    
    var cameraController : CameraController = CameraController()
    var scnView : SCNView!
    var currentFrame : UIImage?

    func receiveFrame(frame: UIImage) {
        self.currentFrame = frame
        //scnView.scene?.background.contents = frame
        // do some cool stuff with the image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let modelView = ModelView()
        scnView = self.view as! SCNView
        scnView.backgroundColor = UIColor.blackColor()
        scnView.scene = modelView
        
        // make scnView a subview of self.view, and set its backgroundcolor to UIColor.clearColor()
        
        cameraController.cameraDelegate = self
        let previewLayer = cameraController.getPreviewLayer()
        previewLayer.frame = self.view.frame
        self.view.layer.addSublayer(previewLayer)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("saveCurrentFrame:"))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
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

