//
//  ViewController.swift
//  ARKitVideoSample
//
//  Created by . SIN on 2017/09/23.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var recordingButton: RecordingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        
        sceneView.isPlaying = true
        
        // 録画ボタン
        self.recordingButton = RecordingButton(self)
        
        let videoUrl = Bundle.main.url(forResource: "video", withExtension: "mp4")!
        let videoNode = createVideoNode(size: 3.0, videoUrl: videoUrl)
        videoNode.position = SCNVector3(0, 0, -5.0)
        sceneView.scene.rootNode.addChildNode(videoNode)

    }
    
    func createVideoNode(size:CGFloat, videoUrl: URL) -> SCNNode {
        // AVPlayerを生成する
        let avPlayer = AVPlayer(url: videoUrl)
        
        //ループ再生
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none;
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.didPlayToEnd),
                                               name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"),
                                               object: avPlayer.currentItem)
        // SKSceneを生成する
        let skScene = SKScene(size: CGSize(width: 1000, height: 1000)) // あまりサイズが小さいと、ビデオの解像度が落ちる

        // AVPlayerからSKVideoNodeの生成する（サイズは、skSceneと同じ大きさにする）
        let skNode = SKVideoNode(avPlayer: avPlayer)
        skNode.position = CGPoint(x: skScene.size.width / 2.0, y: skScene.size.height / 2.0)
        skNode.size = skScene.size
        skNode.yScale = -1.0 // 座標系を上下逆にする
        skNode.play() // 再生開始

        // SKSceneに、SKVideoNodeを追加する
        skScene.addChild(skNode)
        
        // Boxノードを生成して、マテリアルのSKSeceを適用する
        let node = SCNNode()
        node.geometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = skScene
        node.geometry?.materials = [material]
        node.scale = SCNVector3(1.7, 1, 1) // サイズは横長
        return node
    }
    
    // ループ再生
    @objc func didPlayToEnd(notification: NSNotification) {
        let item: AVPlayerItem = notification.object as! AVPlayerItem
        item.seek(to: kCMTimeZero, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
