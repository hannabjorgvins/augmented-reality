
import SceneKit
import AVFoundation

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
    
    func createCameraProjectionMatrixFrom(cameraMatrix: [Double]) {
        let near = Float(cameraNode.camera!.zNear)
        let far = Float(cameraNode.camera!.zFar)
        let width = Float(cameraMatrix[2])
        let height = Float(cameraMatrix[5])
        
        var projection = SCNMatrix4Identity
        projection.m11 = (2 * Float(cameraMatrix[0])) / width
        projection.m12 = (-2 * Float(cameraMatrix[1])) / width
        projection.m13 = (width - (2 * Float(cameraMatrix[2]))) / width
        projection.m22 = (2 * Float(cameraMatrix[4])) / height
        projection.m23 = (-height + (2 * Float(cameraMatrix[5]))) / height
        projection.m33 = (-far - near) / (far - near)
        projection.m34 = (-2 * far * near) / (far - near)
        projection.m43 = -1
        projection.m44 = 0
        
        cameraNode.camera?.setProjectionTransform(projection)
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
