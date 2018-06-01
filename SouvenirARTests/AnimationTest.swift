//
//
//
//let planeNode = SCNNode(geometry: plane)
//let rootNode = SCNNode()
//rootNode.transform = boxNode.transform
//
//planeNode.transform = boxNode.transform
//planeNode.scale = SCNVector3(x: 0, y: 0, z: 0)
//let duration: TimeInterval = 5
//
//let animation = SCNAction.scale(to: 5, duration: duration)
//let moveOutAnimation = SCNAction.move(to: SCNVector3(x: -0.8, y: 0.6, z: -5), duration: duration)
//let flipAnimation = SCNAction.rotateTo(x: 0, y: CGFloat(58.degreesToRadians), z: 0, duration: duration)
//let rootNodeAnimation = SCNAction.rotateTo(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: duration)
//
//planeNode.runAction(animation)
//planeNode.runAction(moveOutAnimation)
//planeNode.runAction(flipAnimation)
//
//rootNode.addChildNode(planeNode)
//rootNode.runAction(rootNodeAnimation)
