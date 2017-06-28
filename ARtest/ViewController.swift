//
//  ViewController.swift
//  ARtest
//
//  Created by Tshepo on 2017/06/27.
//  Copyright © 2017 applord. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController ,ARSCNViewDelegate {
    var carbon: SCNNode!
    var hydro1: SCNNode!
    var hydro2: SCNNode!
    var hydro3: SCNNode!
    var hydro4: SCNNode!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // This visualization covers only detected planes.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the node using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
       let groundShape = SCNPhysicsShape(geometry: plane, options: nil)
        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
        
        
        
    }
    
     func collada2SCNNode(filepath:String) -> SCNNode {
        
        var node = SCNNode()
        
        let scene = SCNScene(named: filepath)
        var nodeArray = scene!.rootNode.childNodes
        node.position = SCNVector3(-0.8, 0.6, -0.6)
        for childNode in nodeArray {
            node.addChildNode(childNode as SCNNode)
        }
        
        return node
        
    }

    @IBOutlet weak var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            if node == carbon
            {
                let move = SCNAction.moveBy(x: 0.5, y: 0, z:0.5,duration: 2)
                let action = SCNAction.rotateBy(x: 0, y: 0, z:CGFloat(2*Double.pi), duration: 10)
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 9
                //node.runAction(action)
                hydro1.runAction(action)
                hydro1.pivot = SCNMatrix4MakeTranslation(carbon.position.x,carbon.position.y,carbon.position.z)
                hydro2.pivot = SCNMatrix4MakeTranslation(carbon.position.x,carbon.position.y,carbon.position.z)
                hydro3.pivot = SCNMatrix4MakeTranslation(carbon.position.x,carbon.position.y,carbon.position.z)
                hydro4.pivot = SCNMatrix4MakeTranslation(carbon.position.x,carbon.position.y,carbon.position.z)
                hydro2.runAction(action)
                hydro3.runAction(action)
                hydro4.runAction(action)
                hydro2.runAction(move)
                hydro3.runAction(move)
                hydro4.runAction(move)
                hydro1.runAction(move)
                SCNTransaction.commit()
                
            }
            
        }
    }
    
    
     func nodeWithAtom(atom: SCNGeometry, molecule: SCNNode, position: SCNVector3) -> SCNNode {
        let node = SCNNode(geometry: atom)
        node.position = position
        molecule.addChildNode(node)
        return node
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sceneView.delegate = self
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        sceneView.gestureRecognizers = [tapRecognizer]
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        
         let methaneMolecule = SCNNode()
        
        // 1 Carbon
         carbon = nodeWithAtom(atom: Atoms.carbonAtom(), molecule: methaneMolecule, position: SCNVector3Make(0,0,0))
        
        // 4 Hydrogen
        hydro1 = nodeWithAtom(atom:Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(-0.4, 0, 0))
        hydro2 = nodeWithAtom(atom:Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(+0.4, 0, 0))
        hydro3 = nodeWithAtom(atom :Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, -0.4, 0))
        hydro4 = nodeWithAtom(atom :Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, +0.4, 0))
        
        
        sceneView.session.run(configuration)
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial!.diffuse.contents = UIColor.yellow
        let molecule = SCNText()
        molecule.string = "Methane"
        molecule.font =  UIFont.boldSystemFont(ofSize: 0.1)
        
        let textNode = SCNNode(geometry: molecule)
        sphere.firstMaterial!.specular.contents = UIColor.red
        textNode.position = SCNVector3(-0.1, 0.1, -0.6)
        
        methaneMolecule.position = SCNVector3(0, 0, -0.6)
        let background = UIImage(named: "IBLBlurred.png")
        sceneView.scene.background.contents = background;
        sceneView.scene.rootNode.addChildNode(textNode)
        sceneView.scene.rootNode.addChildNode(methaneMolecule)
        
        
        
        
    }
    
    
    
}

