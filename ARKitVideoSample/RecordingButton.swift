//
//  RecordingButton.swift
//  ARKitMeasurementSample
//
//  Created by SIN on 2017/09/01.
//  Copyright © 2017年 Classmethod.Inc. All rights reserved.
//
import UIKit
import ReplayKit

class RecordingButton : UIButton {
    
    var isRecording = false
    let height:CGFloat = 50.0
    let width:CGFloat = 100.0
    let viewController: UIViewController!
    let sharedRecorder = RPScreenRecorder.shared()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ viewController: UIViewController) {
        self.viewController = viewController
        
        super.init(frame: CGRect(x:0, y:0, width:width, height:height))
        
        //        layer.position = CGPoint(x: viewController.view.frame.width/2, y:viewController.view.frame.height - height)
        layer.position = CGPoint(x: width/2, y:viewController.view.frame.height - height)
        
        layer.cornerRadius = 10
        layer.borderWidth = 1
        setTitleColor(UIColor.white, for: .normal)
        
        addTarget(self, action: #selector(tapped), for:.touchUpInside)
        
        setAppearance()
        viewController.view.addSubview(self)
    }
    
    @objc func tapped() {
        if !isRecording {
            isRecording = true
            sharedRecorder.startRecording(handler: { (error) in
                if let error = error {
                    print(error)
                }
            })
//            sharedRecorder.isMicrophoneEnabled = true
//            sharedRecorder.startRecording() { (error) in
//                //self.delegate?.didStartRecord()
//                if let error = error {
//                    print(error)
//                    //self.delegate?.didStopWithError(error)
//                }
//            }
        } else {
            isRecording = false
            sharedRecorder.stopRecording(handler: { (previewViewController, error) in
                previewViewController?.previewControllerDelegate = self
                self.viewController.present(previewViewController!, animated: true, completion: nil)
            })
//            sharedRecorder.stopRecording { (previewViewController, error) in
//                if let preview = previewViewController {
//                    preview.previewControllerDelegate = self
//                    self.viewController.present(preview, animated: true, completion: nil)
//                }
//            }
            return
        }
        setAppearance()
    }
    
    
    func setAppearance() {
        var alpha:CGFloat = 1.0
        var title = "REC"
        if isRecording {
            title = ""
            alpha = 0
        }
        setTitle(title, for: .normal)
        backgroundColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: alpha)
        layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: alpha).cgColor
    }
}

extension RecordingButton: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        DispatchQueue.main.async { [unowned previewController] in
            previewController.dismiss(animated: true, completion: nil)
        }
    }
}


