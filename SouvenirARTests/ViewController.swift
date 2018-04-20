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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        boxNode = (boxScene?.rootNode.childNode(withName: "Box", recursively: false))!
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
                    let photosNode = (boxScene?.rootNode.childNode(withName: "Photos", recursively: false))!
                    photosNode.transform = boxNode.transform
                    sceneView.scene.rootNode.addChildNode(photosNode)
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
//        UIView.animate(withDuration: 0.25, animations: {
//            self.statusView.alpha = 0
//            self.statusView.frame = self.statusView.frame.insetBy(dx: 5, dy: 5)
//        })
    }
}

