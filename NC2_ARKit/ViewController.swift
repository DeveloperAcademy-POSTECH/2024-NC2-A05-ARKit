//
//  ViewController.swift

//

import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate  {
    
    @IBOutlet var sceneView: ARSCNView!
    
    // 사운드 플레이어용 속성 추가
    var audioPlayer: AVAudioPlayer?
    var soundIndex = 1
    var currentModelName: String?
    var soundName: String = ""
    
    // 핸드드래그용 노드 추가
    var selectedNode: SCNNode?
    var originalNodePosition: SCNVector3?
    var originalScale: SCNVector3?
    var startY: CGFloat?
    var originalZScale: Float?
    
    // 인벤토리 뷰 컨트롤러 추가
    var inventoryViewController: InventoryViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        //   let scene = SCNScene(named: "art.scnassets/Animated_fire.usdz")!
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //makeEarth()
        //   makeAnotherFire()
        
        
      
        
        // USDZ 파일 로드 (초기 로드)
      
    //    loadUSDZModel(named: "Animated_fire")
        // 버튼으로 인벤토리 생성
        setupInventoryButton()
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
    
    // 사운드 관련 함수
    @objc private func playSound(_ modelName: String?) {
        soundIndex = (soundIndex) % 2 + 1 // 0, 1, 2를 순환
        guard let modelName = modelName else { return }
        if modelName == "Seaside" {
            soundName = "Water_Sound"
        }
        else {
            soundName = "Fire_Sound_\(soundIndex)"
        }
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")  else { return }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
             
            } catch {
                print(error)
            }
        
    }
    
    @objc private func pauseSound(_ modelName: String?) {
        soundIndex = (soundIndex) % 2 + 1 //  1, 2를 순환
        guard let modelName = modelName else { return }
        if modelName == "Seaside" {
            soundName = "Water_Sound"
        }
        else {
            soundName = "Fire_Sound_\(soundIndex)"
        }
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")  else { return }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.pause()
             
            } catch {
                print(error)
            }
        
    }
    
    
    
    // 인벤토리 함수
    func setupInventoryButton() {
        let inventoryButton = UIButton(type: .system)
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let inventoryImage = UIImage(systemName: "square.grid.2x2.fill", withConfiguration: symbolConfiguration)
        inventoryButton.setImage(inventoryImage, for: .normal)
        
        // 색상 설정 (HEX 코드: E1B778)
        inventoryButton.tintColor = UIColor(hex: "#E1B778")
        
        inventoryButton.translatesAutoresizingMaskIntoConstraints = false
        inventoryButton.addTarget(self, action: #selector(inventoryButtonTapped), for: .touchUpInside)
        self.view.addSubview(inventoryButton)
        
        // 오토레이아웃으로 위치 설정
        NSLayoutConstraint.activate([
            inventoryButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            inventoryButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            inventoryButton.widthAnchor.constraint(equalToConstant: 32),
            inventoryButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

   
    @objc func inventoryButtonTapped() {
          let inventoryVC = InventoryViewController()
          inventoryVC.delegate = self
          inventoryVC.modalPresentationStyle = .pageSheet
          if let sheet = inventoryVC.sheetPresentationController {
              sheet.detents = [.medium(), .large()] // 설정 가능한 detents
              sheet.prefersGrabberVisible = false // Grabber를 보이게 설정
              sheet.prefersScrollingExpandsWhenScrolledToEdge = false // 스크롤시 확장 방지
              sheet.prefersEdgeAttachedInCompactHeight = true // Compact height에서 가장자리 붙이기
              sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true // 너비 조정
          }
          present(inventoryVC, animated: true, completion: nil)
      }

    func setupInventoryView() {
           let inventoryVC = InventoryViewController()
           inventoryVC.delegate = self
           addChild(inventoryVC)
           view.addSubview(inventoryVC.view)
           
           inventoryVC.view.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               inventoryVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               inventoryVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               inventoryVC.view.heightAnchor.constraint(equalToConstant: 236),
               inventoryVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
           ])
           
           inventoryVC.didMove(toParent: self)
           self.inventoryViewController = inventoryVC
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
        // 최소  2초동안은 프레싱되어야 제스쳐를 인식합니다
        longPressGestureRecognizer.minimumPressDuration = 2
        // 2초 안에 들어오는 제스쳐는 삭제합니다(버리기)
        longPressGestureRecognizer.delaysTouchesBegan = true
        sceneView.addGestureRecognizer(longPressGestureRecognizer)
        
        // 사운드 재생용 더블 탭 제스쳐 추가
        /*
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapGestureRecognizer)
         */
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
        currentModelName = modelName
      
        // 소리를 재생합니다
        playSound(modelName)
      
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
                if let selectedNode = selectedNode {
                    for i in 1...64 {
                        let nodeName = String(format: "Feu%02d", i)
                        if let fireNode = selectedNode.childNode(withName: nodeName, recursively: true) {
                            if fireNode.isHidden {
                                fireNode.isHidden = false
                                playSound(currentModelName)
                            }
                            else {
                                fireNode.isHidden = true
                                pauseSound(currentModelName)
                            }
                            
                        }
                    }
                    
                    let candleNodeName = "Cone_3"
                   
                    if let candleNode = selectedNode.childNode(withName: candleNodeName, recursively: true) {
                        if let candleInnerNode = candleNode.childNode(withName: "Object_4", recursively: true) {
                            if candleInnerNode.isHidden {
                                candleInnerNode.isHidden = false
                                playSound(currentModelName)
                            }
                            else {
                                candleInnerNode.isHidden = true
                                pauseSound(currentModelName)
                            }
                        }
                       
                        
                    }
                   
                    let starOrbNodeName = "inner_0"
                    
                    
                    if let starOrbInnerNode = selectedNode.childNode(withName: starOrbNodeName, recursively: true) {
                        if let starOrbCenterNode = starOrbInnerNode.childNode(withName: "Object_4", recursively: true) {
                            if let starOrbNode = starOrbCenterNode.childNode(withName: "Object_0", recursively: true) {
                                if starOrbNode.isHidden {
                                    starOrbNode.isHidden = false
                                    playSound(currentModelName)
                                }
                                else {
                                    starOrbNode.isHidden = true
                                    pauseSound(currentModelName)
                                }
                                
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
                // 최상위 노드로 이동
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
    
    func adjustPivot(node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(0, 0, (max.z - min.z) / -2)
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
                if let selectedNode = selectedNode {
                    for i in 1...64 {
                        let nodeName = String(format: "Feu%02d", i)
                        if let fireNode = selectedNode.childNode(withName: nodeName, recursively: true) {
                            let scaleZAction = SCNAction.scaleZ(to: 5, duration: 5.0)
                            adjustPivot(node: fireNode)
                            fireNode.runAction(scaleZAction)
                        }
                    }
                     
                    let candleNodeName = "Cone_3"
                   
                    if let candleNode = selectedNode.childNode(withName: candleNodeName, recursively: true) {
                        if let candleInnerNode = candleNode.childNode(withName: "Object_4", recursively: true) {
                            let scaleYAction = SCNAction.scaleY(to: 5, duration: 5.0)
                            adjustPivot(node: candleInnerNode)
                            candleInnerNode.runAction(scaleYAction)
                            if candleInnerNode.action(forKey: "scaleY") != nil {
                                let scaleYAction = SCNAction.scaleY(to: 1, duration: 5.0)
                                //adjustPivot(node: candleInnerNode)
                                candleInnerNode.runAction(scaleYAction)
                            }
                        }
                    }
                   
                    let starOrbNodeName = "inner_0"
                    if let starOrbInnerNode = selectedNode.childNode(withName: starOrbNodeName, recursively: true) {
                        if let starOrbCenterNode = starOrbInnerNode.childNode(withName: "Object_4", recursively: true) {
                            if let starOrbNode = starOrbCenterNode.childNode(withName: "Object_0", recursively: true) {
                                let scaleAction = SCNAction.scale(to: 5.0, duration: 2.5)
                                starOrbNode.runAction(scaleAction)
                                if starOrbNode.action(forKey: "scale") != nil {
                                    let scaleAction = SCNAction.scale(to: 1.0, duration: 2.5)
                                    starOrbNode.runAction(scaleAction)
                                }
                            }
                            
                        }
                      
                    }
                }
            }
            
        case .ended, .cancelled:
            let hitResults = sceneView.hitTest(location, options: nil)
            if let hitResult = hitResults.first {
                selectedNode = hitResult.node
                while let parent = selectedNode?.parent, parent !== sceneView.scene.rootNode {
                    selectedNode = parent
                }
                originalNodePosition = selectedNode?.position
                originalScale = selectedNode?.scale
                if let selectedNode = selectedNode {
                    for i in 1...64 {
                        let nodeName = String(format: "Feu%02d", i)
                        if let fireNode = selectedNode.childNode(withName: nodeName, recursively: true) {
                            if fireNode.action(forKey: "scaleZ") != nil {
                                let scaleZAction = SCNAction.scaleZ(to: 1, duration: 5.0)
                                adjustPivot(node: fireNode)
                                fireNode.runAction(scaleZAction)
                            }
                            fireNode.removeAllActions()
                        }
                    }
                     
                    let candleNodeName = "Cone_3"
                    if let candleNode = selectedNode.childNode(withName: candleNodeName, recursively: true) {
                        if let candleInnerNode = candleNode.childNode(withName: "Object_4", recursively: true) {
                            candleInnerNode.removeAllActions()
                        }
                    }
                    
                    let starOrbNodeName = "inner_0"
                    if let starOrbInnerNode = selectedNode.childNode(withName: starOrbNodeName, recursively: true) {
                        if let starOrbCenterNode = starOrbInnerNode.childNode(withName: "Object_4", recursively: true) {
                            if let starOrbNode = starOrbCenterNode.childNode(withName: "Object_0", recursively: true) {
                                starOrbNode.removeAllActions()
                            }
                        }
                    }
                }
            }
            selectedNode = nil
            originalNodePosition = nil
            originalScale = nil
            startY = nil
            originalZScale = nil
        default:
            break
        }
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        playSound(currentModelName)
    }
}

// 스케일 z축으로 늘리기(불꽃늘리기) 커스텀 액션
extension SCNAction {
    class func scaleZ(to scale: Float, duration: TimeInterval) -> SCNAction {
        return SCNAction.customAction(duration: duration) { node, elapsedTime in
            let percentageComplete = elapsedTime / CGFloat(duration)
            let initialScale = node.scale.z
            let delta = scale - initialScale
            let newScale =  delta * Float(percentageComplete)
            node.scale.z = newScale
        }
    }
      class func scaleY(to scale: Float, duration: TimeInterval) -> SCNAction {
          return SCNAction.customAction(duration: duration) { node, elapsedTime in
              let percentageComplete = elapsedTime / CGFloat(duration)
              let initialScale = node.scale.y
              let delta = scale - initialScale
              let newScale = initialScale + delta * Float(percentageComplete)
//              let min = node.boundingBox.min
//              let max = node.boundingBox.max
//              node.pivot = SCNMatrix4MakeTranslation(0, 0, (max.z - min.z) / -2)
              node.scale.y = newScale
          }
      }
    
}

// MARK: - 인벤토리 컨트롤러
extension ViewController: InventoryViewControllerDelegate {
    func didSelectModel(named modelName: String) {
        loadUSDZModel(named: modelName)
        dismiss(animated: true, completion: nil)
    }
}


// UIColor 확장 기능을 추가하여 HEX 코드를 UIColor로 변환
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
