//
//  PhotoCollectionCell.swift
//  Zoot
//
//  Created by LoveMobile on 9/21/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import AVKit
import SDWebImage

protocol PhotoCollectionCellDelegate {
    func didRemovePhoto(_ cell: PhotoCollectionCell)
}

class PhotoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var borderView: CardBorderView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addView: CardView!
    @IBOutlet weak var deleteButton: UIButton!
    
    fileprivate var videoPlayer: AVPlayer? = nil
    fileprivate var playerLayer: AVPlayerLayer? = nil
    fileprivate var playerItem: AVPlayerItem? = nil
    
    public var delegate: PhotoCollectionCellDelegate? = nil
    
    public var photo: UIImage? {
        didSet {
            photoImageView.image = photo
            removeVideoPlayer()
            if let _ = photo {
                deleteButton.isHidden = false
                addView.isHidden = true
                borderView.borderWidth = 0.0;
                borderView.layoutSubviews()
            } else {
                deleteButton.isHidden = true
                addView.isHidden = false
                borderView.borderWidth = 1.0;
                borderView.layoutSubviews()
            }
        }
    }
    
    public var video: URL? {
        didSet {
            if let _ = video {
                deleteButton.isHidden = false
                addView.isHidden = true
                borderView.borderWidth = 0.0;
                borderView.layoutSubviews()
            } else {
                deleteButton.isHidden = true
                addView.isHidden = false
                borderView.borderWidth = 1.0;
                borderView.layoutSubviews()
            }
            
            prepareVideoPlayer()
        }
    }
    
    public var photoURL: URL? {
        didSet {
            photoImageView.sd_setImage(with: photoURL, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) in
                
            }
        }
    }
    
    public var index: Int = -1
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layer = playerLayer {
            layer.frame = photoImageView.bounds
        }
    }
    
    fileprivate func prepareVideoPlayer() {
        removeVideoPlayer()
        guard let url = video else {
            return
        }
        playerItem = AVPlayerItem(url: url)
        videoPlayer = AVPlayer(playerItem: playerItem)
        videoPlayer?.isMuted = true
        playerLayer = AVPlayerLayer(player: videoPlayer)
        if let layer = playerLayer {
            photoImageView.layer.addSublayer(layer)
            layer.frame = photoImageView.bounds
            layer.videoGravity = .resizeAspectFill
        }
        
        if let _ = videoPlayer {
            NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerDidEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
        play()
    }
    
    fileprivate func removeVideoPlayer() {
        if let player = videoPlayer {
            player.pause()
            videoPlayer = nil
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
        if let layer = playerLayer {
            layer.removeFromSuperlayer()
            playerLayer = nil
        }
        
        playerItem = nil
    }
    
    public func play() {
        videoPlayer?.play()
    }
    
    public func pause() {
        videoPlayer?.pause()
    }
    
    @objc fileprivate func handlePlayerDidEnd(_ notification: Notification) {
        if let item = notification.object as? AVPlayerItem, item == playerItem {
            videoPlayer?.seek(to: .zero)
            videoPlayer?.play()
        }
    }
    
    // MARK: - IBAction
    @IBAction func deleteAction(_ sender: UIButton?) {
        delegate?.didRemovePhoto(self)
    }
}
