//
//  ViewController.swift

//

import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO


class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate  {
    
    @IBOutlet var sceneView: ARSCNView!
    
    
    // 핸드드래그용 노드 추가
    var selectedNode: SCNNode?
    var originalNodePosition: SCNVector3?
    var originalScale: SCNVector3?
    var startY: CGFloat?
    var originalZScale: Float?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //   let scene = SCNScene(named: "art.scnassets/Animated_fire.usdz")!
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //makeEarth()
        //   makeAnotherFire()
        
        
      
        
        // USDZ 파일 로드 (초기 로드)
      
    //    loadUSDZModel(named: "Animated_fire")
        // 플러스버튼으로 인벤토리 생성
        setupPlusButton()
        // 제스처 인식기 추가
        addGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
      
        // 사람을 인식해서 사람 사이의 거리를 계산하여 객체를 위치시키는 기능
        // 장면에서 사람의 깊이와 관계없이 앱의 가상 콘텐츠에 사람이 겹쳐야 함을 나타내려면  personSegmentation 프레임 시맨틱을 사용합니다.
        // 객체를 강조하기 위해 해당 코드 생략가능(객체가 최상단에 오는것처럼 보입니다)
        configuration.frameSemantics.insert(.personSegmentation)
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
   
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // 인벤토리 함수
    func setupPlusButton() {
        let plusButton = UIButton(type: .system)
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        plusButton.frame = CGRect(x: self.view.frame.width - 60, y: 40, width: 50, height: 50)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        self.view.addSubview(plusButton)
    }
    
    @objc func plusButtonTapped() {
        let inventoryVC = InventoryViewController()
        inventoryVC.delegate = self
        inventoryVC.modalPresentationStyle = .pageSheet
        if let sheet = inventoryVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(inventoryVC, animated: true, completion: nil)
        
    }
       
    
    
   // 제스쳐 함수
    func addGestureRecognizers() {
        // 탭 제스처 추가
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        tapGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // 팬 제스처 추가 (드래그)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
        
        // 핀치 제스처 추가
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        // 롱프레스 제스처 추가
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        // 최소 1,5초동안은 프레싱되어야 제스쳐를 인식합니다
        longPressGestureRecognizer.minimumPressDuration = 1.5
        // 1.5초 안에 들어오는 제스쳐는 삭제합니다(버리기)
        longPressGestureRecognizer.delaysTouchesBegan = true
        sceneView.addGestureRecognizer(longPressGestureRecognizer)
        
    }
    
   
    
    func addAnimation(node: SCNNode) {
        let rotateOneTime = SCNAction.rotateBy(x: 0, y: 0.8, z: 0, duration: 5)
        let moveUp = SCNAction.moveBy(x: 0, y: 0.2, z: 0, duration: 2.5)
        let moveDown = SCNAction.moveBy(x: 0, y: -0.2, z: 0, duration: 2.5)
        let moveSequence = SCNAction.sequence([moveUp, moveDown])
        let rotateAndMove = SCNAction.group([rotateOneTime, moveSequence])
        let actionForever = SCNAction.repeatForever(rotateAndMove)
        
        node.runAction(actionForever)
    }
    
    func addMoveUpDownAnimation(node: SCNNode) {
        
        let moveUp = SCNAction.moveBy(x: 0, y: 3, z: 0, duration: 2.5)
        let moveDown = SCNAction.moveBy(x: 0, y: -0.2, z: 0, duration: 2.5)
        let moveSequence = SCNAction.sequence([moveUp, moveDown])
        
        let actionRepeat = SCNAction.repeatForever(moveSequence)
        
        node.runAction(actionRepeat)
        
    }
       
   
    
    func loadUSDZModel(named modelName: String) {
     
        // sceneView의 씬에서 루트 노드의 모든 자식 노드를 제거
        // forEach 문으로 루트 노드의 모든 자식노드를 돌면서 씬의 루트 노드에 있는 모든 자식 노드를 제거함
        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
       
        guard let url = Bundle.main.url(forResource: "art.scnassets/\(modelName)", withExtension: "usdz"),
              let node = SCNReferenceNode(url: url) else {
            print("USDZ 파일을 찾을 수 없습니다: \(modelName)")
            return
        }
        
        // 일부 객체가 검게 보이는 현상이 있으므로 다시 조명추가해줌
        // 씬에서 오브젝트를 갈아낄때 노드가 삭제되면서 조명(라이팅)이 제거된 것으로 보임
        addLighting()
        
        // 노드를 올립니다
        node.load()
        // Animated_fire 모델의 특성으로 z축으로 떨어져서 보내게 했습니다
        node.position = SCNVector3(x: 0, y: 0, z: -15)
        // 원하는 스케일로 조정
        node.scale = SCNVector3(x: 0.15, y: 0.15, z: 0.15)
        
        
        // 씬의 루트노드에 자식노드를 추가합니다
        sceneView.scene.rootNode.addChildNode(node)
        
        // 핀치 제스쳐 관련으로 selectedNode 속성을 사용했었으나 지금은 쓰지않음(일단 넣어뒀음 - 추후 삭제예정)
        // selectedNode = node
        // addAnimation(node: node)
        originalScale = node.scale
    }
    
    
    func addLighting() {
        let light = SCNLight()
        light.type = .omni
        light.intensity = 1000
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        sceneView.scene.rootNode.addChildNode(lightNode)

        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 500
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        sceneView.scene.rootNode.addChildNode(ambientLightNode)
    }

    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
            let hitResults = sceneView.hitTest(location, options: nil)
            if let hitResult = hitResults.first {
                selectedNode = hitResult.node
                while let parent = selectedNode?.parent, parent !== sceneView.scene.rootNode {
                    selectedNode = parent
                }
                originalNodePosition = selectedNode?.position
                originalScale = selectedNode?.scale
                if let selectedNode = selectedNode, let originalScale = originalScale {
                    for i in 1...64 {
                        let nodeName = String(format: "Feu%02d", i)
                        if let fireNode = selectedNode.childNode(withName: nodeName, recursively: true) {
                            if fireNode.isHidden {
                                fireNode.isHidden = false
                            }
                            else {
                                fireNode.isHidden = true
                            }
                            fireNode.scale = SCNVector3(x: originalScale.x, y: originalScale.y, z: 100)
                        }
                    }
                }
            }
        
       
    }
    
    
    func moveSelectedNode(to transform: matrix_float4x4) {
        guard let selectedNode = selectedNode else { return }
        let position = transform.columns.3
        selectedNode.position = SCNVector3(position.x, position.y, position.z)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        switch gesture.state {
        case .began:
            let hitResults = sceneView.hitTest(location, options: nil)
            if let hitResult = hitResults.first {
                // 최상위 노드로 이동
                selectedNode = hitResult.node
                while let parent = selectedNode?.parent, parent !== sceneView.scene.rootNode {
                    selectedNode = parent
                }
                originalNodePosition = selectedNode?.position
            }
            
        case .changed:
            if let selectedNode = selectedNode, let originalNodePosition = originalNodePosition,let originalScale = originalScale  {
                let translation = gesture.translation(in: sceneView)
                let newPosition = SCNVector3(
                    x: originalNodePosition.x + Float(translation.x * 0.05),
                    y: originalNodePosition.y + Float(translation.y * -0.05),
                    z: originalNodePosition.z + Float(translation.y * -0.05)
                )
                selectedNode.position = newPosition
                // addAnimation(node: selectedNode)
                // addMoveUpDownAnimation(node: selectedNode)
            }
            
        case .ended, .cancelled:
            selectedNode = nil
            originalNodePosition = nil
        default:
            break
        }
    }
    
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let location = gesture.location(in: (gesture.view as! ARSCNView))
        switch gesture.state {
        case .began:
            //  let hitResults = sceneView.hitTest(location, options: nil)
            let hitTest = (gesture.view as! ARSCNView).hitTest(location)
            if let hitTest = hitTest.first {
                // 최상위 노드로 이동
                selectedNode = hitTest.node
                while let parent = selectedNode?.parent, parent !== sceneView.scene.rootNode {
                    selectedNode = parent
                }
                originalNodePosition = selectedNode?.position
            }
        case .changed:
            if let selectedNode = selectedNode, let originalScale = originalScale {
                let scale = Float(gesture.scale)
                selectedNode.scale = SCNVector3(x: originalScale.x * scale, y: originalScale.y * scale, z: originalScale.z * scale)
            }
        case .ended, .cancelled:
            if let selectedNode = selectedNode {
                originalScale = selectedNode.scale
            }
        default:
            break
        }
    }
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
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
                originalScale = selectedNode?.scale
                if let selectedNode = selectedNode, let originalScale = originalScale {
                    for i in 1...64 {
                        let nodeName = String(format: "Feu%02d", i)
                        if let fireNode = selectedNode.childNode(withName: nodeName, recursively: true) {
                            if fireNode.isHidden {
                                fireNode.isHidden = false
                            }
                            else {
                                fireNode.isHidden = true
                            }
                            fireNode.scale = SCNVector3(x: originalScale.x, y: originalScale.y, z: 100)
                        }
                    }
                }
            }
        
        case .ended, .cancelled:
            selectedNode = nil
            originalNodePosition = nil
            originalScale = nil
            startY = nil
            originalZScale = nil
        default:
            break
        }
    }

}
    extension SCNAction {
        class func scale(to scale: CGFloat, duration: TimeInterval) -> SCNAction {
            return SCNAction.customAction(duration: duration) { node, elapsedTime in
                let initialScale = node.scale
                let delta = scale - CGFloat(initialScale.z)
                let percentageComplete = elapsedTime / CGFloat(duration)
                node.scale = SCNVector3(
                    x: initialScale.x,
                    y: initialScale.y,
                    z: Float(CGFloat(initialScale.z) + delta * percentageComplete)
                )
            }
        }
    }

// MARK: - 인벤토리 컨트롤러
extension ViewController: InventoryViewControllerDelegate {
    func didSelectModel(named modelName: String) {
        loadUSDZModel(named: modelName)
    }
}

