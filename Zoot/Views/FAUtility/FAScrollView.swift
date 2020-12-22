//
//  FAScrollView.swift
//  FAImageCropper
//
//  Created by Fahid Attique on 12/02/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit
import AVKit

protocol FAScrollViewPlayDelegate {
    func didStartPlayVideo(_ scrollView: FAScrollView)
    func didStopPlayVideo(_ scrollView: FAScrollView)
}

class FAScrollView: UIScrollView {

    // MARK: Class properties
    
    var imageView = UIImageView()
    var player: AVPlayer? = nil
    var playerLayer: AVPlayerLayer? = nil
    var imageToDisplay: UIImage? = nil {
        didSet {
            zoomScale = 1.0
            minimumZoomScale = 1.0
            imageView.image = imageToDisplay
            imageView.frame.size = sizeForImageToDisplay()
            imageView.center = center
            contentSize = imageView.frame.size
            contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            updateLayout()
        }
    }
    var videoToDisplay: URL? = nil {
        didSet {
            if let url = videoToDisplay {
                self.imageToDisplay = VideoManager.shared.thumbImage(url: url)
                prepareVideoPlayer(url)
            } else {
                removeVideoPlayer()
            }
        }
    }
    public var startTime: CMTime? = nil
    public var endTime: CMTime? = nil
    public var gridView: UIView = Bundle.main.loadNibNamed("FAGridView", owner: nil, options: nil)?.first as! UIView
    public var playDelegate: FAScrollViewPlayDelegate? = nil
    public private(set) var isPlaying = false
    public var isMuted: Bool {
        get {
            if let player = self.player {
                return player.isMuted
            }
            
            return false
        }
    }

    // MARK : Class Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        viewConfigurations()
    }

    func updateLayout() {
        imageView.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0);
        var frame:CGRect = imageView.frame;
        if (frame.origin.x < 0) { frame.origin.x = 0 }
        if (frame.origin.y < 0) { frame.origin.y = 0 }
        imageView.frame = frame
    }
    
    func zoom() {
        if (zoomScale <= 1.0) { setZoomScale(zoomScaleWithNoWhiteSpaces(), animated: true) }
        else{ setZoomScale(minimumZoomScale, animated: true) }
        updateLayout()
    }
    
    
    
    // MARK: Private Functions
    private func viewConfigurations(){
        
        clipsToBounds = false;
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
        bouncesZoom = true
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self
        maximumZoomScale = 5.0
        addSubview(imageView)
        
        gridView.frame = frame
        gridView.isHidden = true
        gridView.isUserInteractionEnabled = false
        addSubview(gridView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        gesture.delegate = self
        addGestureRecognizer(gesture)
    }
    
    private func sizeForImageToDisplay() -> CGSize{
        
        var actualWidth:CGFloat = imageToDisplay!.size.width
        var actualHeight:CGFloat = imageToDisplay!.size.height
        var imgRatio:CGFloat = actualWidth/actualHeight
        let maxRatio:CGFloat = frame.size.width/frame.size.height
        
        if imgRatio != maxRatio{
            if(imgRatio > maxRatio){
                imgRatio = frame.size.height / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = frame.size.height
            }
            else{
                imgRatio = frame.size.width / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = frame.size.width
            }
        }
        else {
            imgRatio = frame.size.width / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = frame.size.width
        }

        return  CGSize(width: actualWidth, height: actualHeight)
    }
    
    private func zoomScaleWithNoWhiteSpaces() -> CGFloat{
        
        let imageViewSize:CGSize  = imageView.bounds.size
        let scrollViewSize:CGSize = bounds.size;
        let widthScale:CGFloat  = scrollViewSize.width / imageViewSize.width
        let heightScale:CGFloat = scrollViewSize.height / imageViewSize.height
        let scale = max(widthScale, heightScale)
        minimumZoomScale = scale
        return scale
    }

    // MARK: - Video Player
    fileprivate func prepareVideoPlayer(_ url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        if let layer = playerLayer {
            imageView.layer.addSublayer(layer)
        }
        playerLayer?.frame = imageView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        if let _ = self.player {
            NotificationCenter.default.addObserver(self, selector: #selector(handleDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    fileprivate func removeVideoPlayer() {
        if let layer = playerLayer {
            layer.removeFromSuperlayer()
            playerLayer = nil
        }
        
        if let player = self.player {
            player.pause()
            self.player = nil
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    @objc fileprivate func handleDidPlayToEndTime(_ notification: Notification) {
        if let startTime = startTime {
            player?.seek(to: startTime, toleranceBefore: .zero, toleranceAfter: .zero)
        } else {
            player?.seek(to: .zero)
        }
        if isPlaying {
            player?.play()
        }
    }
    
    @objc fileprivate func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let player = player else {
            return
        }
        
        if player.rate == 0 {
            player.play()
            playDelegate?.didStartPlayVideo(self)
            isPlaying = true
        } else {
            player.pause()
            playDelegate?.didStopPlayVideo(self)
            isPlaying = false
        }
    }
    
    public func play() {
        if let player = player {
            player.play()
            playDelegate?.didStartPlayVideo(self)
            isPlaying = true
        }
    }
    
    public func pause() {
        if let player = player {
            player.pause()
            playDelegate?.didStopPlayVideo(self)
            isPlaying = false
        }
    }
    
    public func mute(_ isMuted: Bool) {
        if let player = player {
            player.isMuted = isMuted
        }
    }
    
    public func currentTime() -> CMTime {
        if let player = player {
            return player.currentTime()
        } else {
            return .zero
        }
    }
    
    public func seek(_ time: CMTime) {
        if let player = player {
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
}

extension FAScrollView:UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateLayout()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        gridView.isHidden = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        gridView.isHidden = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        var frame:CGRect = gridView.frame;
        frame.origin.x = scrollView.contentOffset.x
        frame.origin.y = scrollView.contentOffset.y
        gridView.frame = frame
        
        switch scrollView.pinchGestureRecognizer!.state {
        case .changed:
            gridView.isHidden = false
            break
        case .ended:
            gridView.isHidden = true
            break
        default: break
        }
        
    }
}

extension FAScrollView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        
        return true
    }
}
