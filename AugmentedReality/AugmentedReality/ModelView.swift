
import SceneKit

class ModelView : SCNScene {
    
    let cameraNode = SCNNode()
    let objectNode = SCNNode()
    
    override init() {
        super.init()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        let boxGeometry = SCNBox(width: 5.0, height: 5.0, length: 5.0, chamferRadius: 0.0)
        objectNode.addChildNode(SCNNode(geometry: boxGeometry))
        objectNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(2, y: 2, z: 2, duration: 1)))
        
        self.rootNode.addChildNode(cameraNode)
        self.rootNode.addChildNode(objectNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
