
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
        self.rootNode.addChildNode(cameraNode)
        self.rootNode.addChildNode(objectNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideObject() {
        objectNode.removeFromParentNode()
    }
    
    func showObject() {
        self.rootNode.addChildNode(objectNode)
    }
    
    func setCameraTransformationMatrixTo(transformationMatrix: [Double]) {
        var transformation = SCNMatrix4()
        transformation.m11 = Float(transformationMatrix[0])
        transformation.m12 = Float(transformationMatrix[1])
        transformation.m13 = Float(transformationMatrix[2])
        transformation.m14 = Float(transformationMatrix[3])
        transformation.m21 = Float(transformationMatrix[4])
        transformation.m22 = Float(transformationMatrix[5])
        transformation.m23 = Float(transformationMatrix[6])
        transformation.m24 = Float(transformationMatrix[7])
        transformation.m31 = Float(transformationMatrix[8])
        transformation.m32 = Float(transformationMatrix[9])
        transformation.m33 = Float(transformationMatrix[10])
        transformation.m34 = Float(transformationMatrix[11])
        transformation.m41 = Float(transformationMatrix[12])
        transformation.m42 = Float(transformationMatrix[13])
        transformation.m43 = Float(transformationMatrix[14])
        transformation.m44 = Float(transformationMatrix[15])
        cameraNode.transform = transformation
    }
    
}
