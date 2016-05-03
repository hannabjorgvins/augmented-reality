
import SceneKit

class ModelView : SCNScene {
    
    let cameraNode = SCNNode()
    let objectNode = SCNNode()
    
    override init() {
        super.init()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        let boxGeometry = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.0)
        objectNode.addChildNode(SCNNode(geometry: boxGeometry))
        objectNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(2, y: 2, z: 2, duration: 1)))
        
        self.rootNode.addChildNode(cameraNode)
        self.rootNode.addChildNode(objectNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
