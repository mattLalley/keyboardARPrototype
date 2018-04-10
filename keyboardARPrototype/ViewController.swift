//
//  ViewController.swift
//  World Tracking
//
//  Created by Matthew Lalley on 4/8/18.
//  Copyright © 2018 Matthew Lalley. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!

    let itemsArray: [String] = ["board1", "board1", "board1", "board1"]
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)

        self.sceneView.autoenablesDefaultLighting = true

        self.registerGestureRecognizers()

        self.itemsCollectionView.dataSource = self
        self.itemsCollectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! ARSCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates, types: .existingPlaneUsingExtent)
        if (!hitTest.isEmpty) {
            self.addKeyboard(hitTestResult: hitTest.first!)
        }
    }

    func addKeyboard(hitTestResult: ARHitTestResult) {
        guard let selectedItem = self.selectedItem else { return }
        let keyboardScene = SCNScene(named: "art.scnassets/\(selectedItem).scn")
        guard let node = keyboardScene?.rootNode.childNode(withName: "keyboard", recursively: false) else {return}
        let transform = hitTestResult.worldTransform
        let thirdColomn = transform.columns.3
        node.position = SCNVector3(thirdColomn.x, thirdColomn.y, thirdColomn.z)
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        self.sceneView.scene.rootNode.addChildNode(node)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "board", for: indexPath) as! boardCell
        cell.boardLabel.text = self.itemsArray[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = itemsArray[indexPath.row]
        cell?.backgroundColor = UIColor.green
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension Int {
    var degreeToRadians: Double { return Double(self) * .pi/180 }
}
