//
//  ViewController.swift
//  SouvenirARTests
//
//  Created by IJke Botman on 13/04/2018.
//  Copyright © 2018 IJke Botman. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusView: UIVisualEffectView!
    @IBOutlet weak var statusViewLabel: UILabel!
    
    var boxIsVisible = false
    var photosAreVisible = false
    let boxScene = SCNScene(named: "Models.scnassets/BoxScene.scn")
    var boxNode = SCNNode()
    var boxLidNode = SCNNode()
    var localPhotos = [UIImage]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localPhotos.append(UIImage(named: "0")!)
        localPhotos.append(UIImage(named: "0")!)
        localPhotos.append(UIImage(named: "0")!)
        localPhotos.append(UIImage(named: "0")!)
        localPhotos.append(UIImage(named: "0")!)
        localPhotos.append(UIImage(named: "0")!)
        localPhotos.append(UIImage(named: "0")!)
        localPhotos.append(UIImage(named: "0")!)
        
        
       
        
       
        
        sceneView.delegate = self
        
        boxNode = (boxScene?.rootNode.childNode(withName: "Box", recursively: false))!
        boxLidNode = boxNode.childNode(withName: "BoxLid", recursively: false)!
        boxNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        boxNode.name = "Box"
        
        boxNode.isHidden = true
        sceneView.scene.rootNode.addChildNode(boxNode)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        // Prevent the screen from being dimmed after a while.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start a new session
        startNewSession()
    }
    
    func startNewSession() {
        // hide toast
        self.statusView.alpha = 0
        self.statusView.frame = self.statusView.frame.insetBy(dx: 5, dy: 5)
        
        
        // Create a session configuration with horizontal plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene.isPaused = true

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        // When tapped on the object, call the object's method to react on it
        let sceneHitTestResult = sceneView.hitTest(location, options: nil)
        if !sceneHitTestResult.isEmpty {
            // We only have one content, so we know which node was hit.
            // If the scene contains multiple objects, you would need to check here if the right node was hit
            if sceneHitTestResult.first?.node.name == "Box" {
                showStatus("Tapped Box")
                
                if photosAreVisible == false {
                    testAnimation()
                    sceneView.scene.isPaused = false
                    photosAreVisible = true
                }
            }
            return
        }
        // When tapped on a plane, reposition the content
        let arHitTestResult = sceneView.hitTest(location, types: .existingPlane)
        if !arHitTestResult.isEmpty {
            let hit = arHitTestResult.first!
            boxNode.simdTransform = hit.worldTransform
        }
    }
    
    func scaleImages(image: UIImage) -> CGFloat{
        
        let ratio = 2 / image.size.width
        
        return ratio
    }
    
    func testAnimation() {

        var angle: Float = -.pi / 2
        let radius: Float = -4.0
        let angleIncrement: Float = (.pi) * 2.0 / Float(localPhotos.count)
        let duration: TimeInterval = 2

        let rootNode = SCNNode()
        rootNode.position = boxNode.position
        var rotateAndScaleAction = SCNAction()
        let scaleAction = SCNAction.scale(to: 1, duration: duration)
        scaleAction.timingMode = .easeInEaseOut
        var boxLidAction = SCNAction()
        let boxMoveFirst = SCNAction.move(by: SCNVector3(0, 0.2, 0), duration: duration)
        let boxMoveSecond = SCNAction.move(by: SCNVector3(0.2, -0.2, 0), duration: duration)
        let boxRotateFirst = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(-90.degreesToRadians), duration: duration)
//        let boxRotateSecond = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: duration)
        let boxMoveAction = SCNAction.sequence([boxMoveSecond, boxRotateFirst])
        boxLidAction = SCNAction.sequence([boxMoveFirst, boxMoveAction])
        
        
        for photo in localPhotos {
            let ratio = self.scaleImages(image: photo)
            
            let plane = SCNPlane(width: 0, height: 0)
            plane.width = photo.size.width * ratio
            plane.height = photo.size.height * ratio
            
            plane.firstMaterial?.diffuse.contents = photo
            let planeNode = SCNNode(geometry: plane)
            
            let x = boxNode.position.x - cos(angle) * radius
            let z = boxNode.position.z - sin(angle) * radius
            let planeNodePosition = SCNVector3(x, 1, z)
            planeNode.eulerAngles.y = -.pi / 2 - angle

            angle += angleIncrement
            
            //animations
            
            planeNode.position = boxNode.position
            print("box position",boxNode.position)
            print("planenode",planeNode.position)
            
            
            let moveAction = SCNAction.move(to: planeNodePosition, duration: duration)
            moveAction.timingMode = .easeInEaseOut
            
            planeNode.scale = SCNVector3(x: 0, y: 0, z: 0)
            
            
            rotateAndScaleAction = SCNAction.group([moveAction, scaleAction])
            
            
//            let planeFlipAnimation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: duration)
//            planeNode.runAction(planeFlipAnimation)
            
            rootNode.addChildNode(planeNode)
            planeNode.runAction(rotateAndScaleAction)
        }
        
        let rootNodeAnimation = SCNAction.rotateTo(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: duration + 2.5)
        rootNodeAnimation.timingMode = .easeInEaseOut
        rootNode.runAction(rootNodeAnimation)
        boxLidNode.runAction(boxLidAction)

        sceneView.scene.rootNode.addChildNode(rootNode)
    }
    
    
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        // Drag the object on an infinite plane
        let arHitTestResult = sceneView.hitTest(location, types: .existingPlane)
        if !arHitTestResult.isEmpty {
            let hit = arHitTestResult.first!
            boxNode.simdTransform = hit.worldTransform
            showStatus("Moving box.")
            
            if sender.state == .ended {
                showStatus("Stopped moving box.")
                
                DispatchQueue.main.async {
                    self.hideStatus()
                }
            }
        }
    }
    
    @IBAction func didPinch(_ sender: UIPinchGestureRecognizer) {
        showStatus("Pinching")
    }
    
    @IBAction func didRotate(_ sender: UIRotationGestureRecognizer) {
        showStatus("Rotating")
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
//            let moveAction = SCNAction.move(to: anchor.transform.translation, duration: 20)
//            boxNode.runAction(moveAction)
            boxNode.simdTransform = anchor.transform
            boxNode.isHidden = false
        }
        DispatchQueue.main.async {
            self.hideStatus()
        }
    }
}

extension ViewController: ARSessionObserver {
    
    func sessionWasInterrupted(_ session: ARSession) {
        showStatus("Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        startNewSession()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showStatus("Session failed: \(error.localizedDescription)")
        startNewSession()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var message: String? = nil
        
        switch camera.trackingState {
        case .notAvailable:
            message = "Tracking not available"
        case .limited(.initializing):
            message = "Initializing AR session"
        case .limited(.excessiveMotion):
            message = "Too much motion"
        case .limited(.insufficientFeatures):
            message = "Not enough surface details"
        case .normal:
            if !boxIsVisible {
                message = "Move to find a horizontal surface"
            }
        default:
            // We are only concerned with the tracking states above.
            message = "Camera changed tracking state"
        }
        message != nil ? showStatus(message!) : hideStatus()
    }
}

extension ViewController {
    
    func showStatus(_ text: String) {
        statusViewLabel.text = text
        
        guard statusView.alpha == 0 else {
            return
        }
        statusView.layer.masksToBounds = true
        statusView.layer.cornerRadius = 7.5
        
        UIView.animate(withDuration: 0.25, animations: {
            self.statusView.alpha = 1
            self.statusView.frame = self.statusView.frame.insetBy(dx: -5, dy: -5)
        })
    }
    
    func hideStatus() {
        UIView.animate(withDuration: 0.25, delay: 1, animations: {
            self.statusView.alpha = 0
            self.statusView.frame = self.statusView.frame.insetBy(dx: 5, dy: 5)
        })
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180}
}

extension float4x4 {
    var translation: SCNVector3 {
        let translation = self.columns.3
        return SCNVector3(translation.x, translation.y, translation.z)
    }
}
