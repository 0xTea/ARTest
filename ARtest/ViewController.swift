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
    
    let collisionRollingBall: Int = 1 << 0
    let collsionTarget: Int = 1 << 1
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // This visualization covers only detected planes.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the node using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        //adding texture to plane drawing
        var material = SCNMaterial()
        let img = UIImage(named:"tron_grid.png");
        material.diffuse.contents = img;
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        let groundShape = SCNPhysicsShape(geometry: plane, options: nil)
        let groundBody = SCNPhysicsBody(type: .kinematic, shape: groundShape)
        planeNode.physicsBody = groundBody
        
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
        setupscene()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            hydro1.physicsBody?.isAffectedByGravity = true
            if node == carbon
            {
                SCNTransaction.begin()
                hydro1.physicsBody?.isAffectedByGravity = true // dropping of one node at gravitional pull
                hydro1.physicsBody?.contactTestBitMask = 0 // testing
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
        
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        
    }
    func setupscene()
    {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        sceneView.gestureRecognizers = [tapRecognizer]
        
        
        //
        let methaneMolecule = SCNNode()
        let carbonshape = SCNPhysicsShape(geometry:  Atoms.carbonAtom(), options: nil)
        let hydroshape = SCNPhysicsShape(geometry:  Atoms.hydrogenAtom(), options: nil)
        
        
        //defining physics body for spheres
        let carbonBody = SCNPhysicsBody(type: .dynamic, shape: carbonshape)
        let hydrobody  = SCNPhysicsBody(type: .dynamic, shape: hydroshape)
        
       //testing collison
        hydrobody.categoryBitMask = 0xFFFFFFFF
        hydrobody.contactTestBitMask = 0xFFFFFFFF
        
        carbonBody.isAffectedByGravity = false
        hydrobody.isAffectedByGravity = false
        
        // 1 Carbon
        carbon = nodeWithAtom(atom: Atoms.carbonAtom(), molecule: methaneMolecule, position: SCNVector3Make(0,0,0))
        carbon.physicsBody = carbonBody
        
        // 4 Hydrogen
        hydro1 = nodeWithAtom(atom:Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(-0.04, 0, 0))
        hydro2 = nodeWithAtom(atom:Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(+0.04, 0, 0))
        hydro3 = nodeWithAtom(atom :Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, -0.04, 0))
        hydro4 = nodeWithAtom(atom :Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, +0.04, 0))
        
        hydro1.physicsBody = hydrobody
        
        let molecule = SCNText()
        molecule.string = "Methane"
        molecule.font =  UIFont.boldSystemFont(ofSize: 0.1)
        let textNode = SCNNode(geometry: molecule)
        textNode.position = SCNVector3(-0.1, 0.1, -0.6)
        
        //texture spherical mapping
        methaneMolecule.position = SCNVector3(0, 0, -0.6)
        let background = UIImage(named: "IBLBlurred.png")
        
        sceneView.scene.background.contents = background;
        sceneView.scene.rootNode.addChildNode(textNode)
        sceneView.scene.rootNode.addChildNode(methaneMolecule)
        
    }
    
    
    
}

