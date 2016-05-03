
import SceneKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let modelView = ModelView()
        let scnView = self.view as! SCNView
        scnView.backgroundColor = UIColor.blackColor()
        scnView.scene = modelView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

