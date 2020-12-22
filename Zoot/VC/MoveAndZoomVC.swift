//
//  MoveAndZoomVC.swift
//  DemoAdam
//
//  Created by mac on 10/09/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import AVKit
import DynamicBlurView

protocol MoveAndZoomVCDelegate {
    func didCropImage(_ image: UIImage)
    func didCropTrimVideo(_ url: URL)
}

class MoveAndZoomVC: UIViewController , UIScrollViewDelegate {
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var scrollView: FAScrollView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var playView: DynamicBlurView!
    
    @IBOutlet weak var topDoneConstraint: NSLayoutConstraint!
    
    private var croppedImage: UIImage? = nil
    private var isFirstLayout = true
    private var seekTimer: Timer? = nil
    
    public var delegate: MoveAndZoomVCDelegate? = nil
    var image: UIImage? = nil
    var videoURL: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.playDelegate = self
        trimmerView.delegate = self
        playView.blurRadius = 10
        playView.trackingMode = .tracking
        playView.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstLayout {
            isFirstLayout = false
            self.view.layoutIfNeeded()
            if let image = self.image {
                self.scrollView.imageToDisplay = image
                trimmerView.isHidden = true
                topDoneConstraint.constant = 44
                playView.isHidden = true
                muteButton.isHidden = true
            } else {
                self.scrollView.videoToDisplay = videoURL
                trimmerView.isHidden = false
                topDoneConstraint.constant = 88
                trimmerView.asset = AVURLAsset(url: videoURL!)
                scrollView.startTime = trimmerView.startTime
                scrollView.endTime = trimmerView.endTime
            }
            scrollView.zoom()
            scrollView.updateLayout()
            playView.refresh()
        }
    }
    
    fileprivate func startSeekTimer() {
        stopSeekTimer()
        seekTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(handleSeekTimer(_:)), userInfo: nil, repeats: true)
    }
    
    fileprivate func stopSeekTimer() {
        if let timer = seekTimer {
            timer.invalidate()
            seekTimer = nil
        }
    }
    
    @objc fileprivate func handleSeekTimer(_ timer: Timer) {
        guard let _ = videoURL else {
            return
        }
        
        var currentTime = scrollView.currentTime()
        if let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, CMTimeGetSeconds(currentTime) >= CMTimeGetSeconds(endTime) {
            scrollView.seek(startTime)
            currentTime = startTime
        }
        trimmerView.seek(to: currentTime)
    }

    // MARK: - IBAction
    @IBAction func backTapped(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
        stopSeekTimer()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showTapped(_ sender: Any) {
        
        //let vc =  self.storyboard?.instantiateViewController(withIdentifier: "ImageDetailVc") as! ImageDetailVc
        //vc.image = captureVisibleRect()
        
        stopSeekTimer()
        if let _ = image {
            delegate?.didCropImage(captureVisibleRect())
            //self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        } else {
            trimCropVideo { (outputURL) in
                self.delegate?.didCropTrimVideo(outputURL!)
                //self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func muteTapped(_ sender: Any) {
        muteButton.isSelected = !muteButton.isSelected
        scrollView.mute(muteButton.isSelected)
    }
    
    @IBAction func playTapped(_ sender: Any) {
        scrollView.play()
    }
    
    private func trimCropVideo(_ completion: @escaping (_ outputURL: URL?) -> Void) {
        let filename = generateRandomFileName(fileExtension: VIDEO_EXTENSION)
        let path = generateVideoFilePath(filename: filename)
        
        var cropRect = CGRect.zero
        let xOffset = scrollView.imageToDisplay!.size.width / scrollView.contentSize.width;
        let yOffset = scrollView.imageToDisplay!.size.height / scrollView.contentSize.height;
        
        cropRect.origin.x = scrollView.contentOffset.x * xOffset;
        cropRect.origin.y = scrollView.contentOffset.y * yOffset;
        
        let normalizedWidth = (scrollView?.frame.width)! / (scrollView?.contentSize.width)!
        let normalizedHeight = (scrollView?.frame.height)! / (scrollView?.contentSize.height)!
        
        cropRect.size.width = scrollView.imageToDisplay!.size.width * normalizedWidth
        cropRect.size.height = scrollView.imageToDisplay!.size.height * normalizedHeight
        
        VideoManager.shared.trimCropVideo(url: videoURL!, outputURL: URL(fileURLWithPath: path), startTime: CMTimeGetSeconds(trimmerView.startTime!), endTime: CMTimeGetSeconds(trimmerView.endTime!), outputFrame: cropRect, isMuted: scrollView.isMuted) { (success, outputURL, error) in
            completion(outputURL)
        }
    }
  
    private func captureVisibleRect() -> UIImage {
        var croprect = CGRect.zero
        let xOffset = scrollView.imageToDisplay!.size.width / scrollView.contentSize.width;
        let yOffset = scrollView.imageToDisplay!.size.height / scrollView.contentSize.height;
        
        croprect.origin.x = scrollView.contentOffset.x * xOffset;
        croprect.origin.y = scrollView.contentOffset.y * yOffset;
        
        let normalizedWidth = (scrollView?.frame.width)! / (scrollView?.contentSize.width)!
        let normalizedHeight = (scrollView?.frame.height)! / (scrollView?.contentSize.height)!
        
        croprect.size.width = scrollView.imageToDisplay!.size.width * normalizedWidth
        croprect.size.height = scrollView.imageToDisplay!.size.height * normalizedHeight
        
        let cropImage = scrollView.imageView.image?.fixImageOrientation()
        let cgImage: CGImage? = cropImage?.cgImage?.cropping(to: croprect)
        let cropped = UIImage(cgImage: cgImage!)
        
        return cropped
    }
}

extension MoveAndZoomVC: FAScrollViewPlayDelegate {
    func didStartPlayVideo(_ scrollView: FAScrollView) {
        playView.isHidden = true
        startSeekTimer()
    }
    
    func didStopPlayVideo(_ scrollView: FAScrollView) {
        playView.isHidden = false
        playView.refresh()
        stopSeekTimer()
    }
}

extension MoveAndZoomVC: TrimmerViewDelegate {
    func didChangePositionBar(_ playerTime: CMTime) {
        scrollView.pause()
        scrollView.startTime = trimmerView.startTime
        scrollView.endTime = trimmerView.endTime
        scrollView.seek(playerTime)
        stopSeekTimer()
    }
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        scrollView.pause()
        scrollView.startTime = trimmerView.startTime
        scrollView.endTime = trimmerView.endTime
        stopSeekTimer()
    }
}
