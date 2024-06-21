
override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self
    let scene = SCNScene()
    sceneView.scene = scene
}

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let configuration = ARWorldTrackingConfiguration()
    configuration.frameSemantics.insert(.personSegmentation)
    sceneView.session.run(configuration)
}

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
}


func loadUSDZModel(named modelName: String) {
    sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
    guard let url = Bundle.main.url(forResource: "art.scnassets/\(modelName)", withExtension: "usdz"),
          let node = SCNReferenceNode(url: url) else {
        print("USDZ 파일을 찾을 수 없습니다: \(modelName)")
        return
    }
    node.load()
    node.position = SCNVector3(x: 0, y: 0, z: -15)
    node.scale = SCNVector3(x: 0.15, y: 0.15, z: 0.15)
    sceneView.scene.rootNode.addChildNode(node)
}



@objc func handleTap(gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: sceneView)
    let hitResults = sceneView.hitTest(location, options: nil)
    if let hitResult = hitResults.first {
        selectedNode = hitResult.node
        while let parent = selectedNode?.parent, parent !== sceneView.scene.rootNode {
            selectedNode = parent
        }
        if let selectedNode = selectedNode {
            let candleNodeName = "Cone_3"
            if let candleNode = selectedNode.childNode(withName: candleNodeName, recursively: true) {
                if let candleInnerNode = candleNode.childNode(withName: "Object_4", recursively: true) {
                    if candleInnerNode.isHidden {
                        candleInnerNode.isHidden = false
                    }
                    else {
                        candleInnerNode.isHidden = true
                    }
                }
            }
        }
    }
}



@objc func handlePan(_ gesture: UIPanGestureRecognizer) {
    let location = gesture.location(in: sceneView)
    switch gesture.state {
    case .began:
        let hitResults = sceneView.hitTest(location, options: nil)
        if let hitResult = hitResults.first {
            selectedNode = hitResult.node
            while let parent = selectedNode?.parent, parent !== sceneView.scene.rootNode {
                selectedNode = parent
            }
            originalNodePosition = selectedNode?.position
        }
    case .changed:
        if let selectedNode = selectedNode, let originalNodePosition = originalNodePosition  {
            let translation = gesture.translation(in: sceneView)
            let newPosition = SCNVector3(
                x: originalNodePosition.x + Float(translation.x * 0.05),
                y: originalNodePosition.y + Float(translation.y * -0.05),
                z: originalNodePosition.z + Float(translation.y * -0.05)
            )
            selectedNode.position = newPosition
        }
    case .ended, .cancelled:
        selectedNode = nil
        originalNodePosition = nil
    default:
        break
    }
}


class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate  {
    @IBOutlet var sceneView: ARSCNView!
    
    
    ...
    
}
    
