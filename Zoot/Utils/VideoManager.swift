//
//  SEVideoManager.swift
//  StoriesEditor
//
//  Created by LoveMobile on 4/28/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoManager: NSObject {

    static let shared = VideoManager()
    
    public typealias CompleteHandler = (Bool, URL?, Error?) -> Void
    
    func videoSize(asset: AVAsset) -> CGSize {
        if let assetTrack = asset.tracks(withMediaType: .video).first {
            let transform = assetTrack.preferredTransform
            let renderSize = assetTrack.naturalSize
            if (transform.b == 1 && transform.c == -1) || (transform.b == -1 && transform.c == 1) {
                return CGSize(width: renderSize.height, height: renderSize.width)
            } else if (renderSize.width == transform.tx && renderSize.height == transform.ty) || (transform.tx == 0 && transform.ty == 0) {
                return renderSize
            } else {
                return CGSize(width: renderSize.height, height: renderSize.width)
            }
        }
        
        return .zero
    }
    
    func videoSize(url: URL) -> CGSize {
        return videoSize(asset: AVURLAsset(url: url))
    }
    
    func thumbImage(asset: AVAsset) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero
        do {
            let imageRef = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
    
    func thumbImage(url: URL) -> UIImage? {
        return thumbImage(asset: AVURLAsset(url: url))
    }
    
    func saveVideoToLocal(asset: AVAsset, outputURL: URL, completion: @escaping CompleteHandler) -> AVAssetExportSession? {
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously {
                DispatchQueue.main.async {
                    if let error = exportSession.error {
                        completion(false, nil, error)
                    } else {
                        completion(true, exportSession.outputURL, nil)
                    }
                }
            }
        }
        completion(false, nil, nil)
        return nil
    }
    
    func trimVideo(url: URL, outputURL: URL, startTime: Float64, endTime: Float64, completion: @escaping CompleteHandler)  {
        let asset = AVURLAsset(url: url)
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.timeRange = CMTimeRange(start: CMTimeMakeWithSeconds(startTime, preferredTimescale: asset.duration.timescale), end: CMTimeMakeWithSeconds(endTime, preferredTimescale: asset.duration.timescale))
            exportSession.exportAsynchronously {
                DispatchQueue.main.async {
                    if let error = exportSession.error {
                        completion(false, nil, error)
                    } else {
                        completion(true, exportSession.outputURL, nil)
                    }
                }
            }
        } else {
            completion(false, nil, nil)
        }
    }
    
    func trimCropVideo(url: URL, outputURL: URL, startTime: Float64, endTime: Float64, outputFrame: CGRect, completion: @escaping CompleteHandler)  {
        let asset = AVURLAsset(url: url)
        let assetTrack = asset.tracks(withMediaType: .video).first!
        var renderSize = assetTrack.naturalSize
        renderSize = outputFrame.size
        var transform = assetTrack.preferredTransform
        /*if (transform.b == 1 && transform.c == -1) || (transform.b == -1 && transform.c == 1) {
            renderSize = CGSize(width: renderSize.height, height: renderSize.width)
        } else if (renderSize.width == transform.tx && renderSize.height == transform.ty) || (transform.tx == 0 && transform.ty == 0) {
            renderSize = CGSize(width: renderSize.width, height: renderSize.height)
        } else {
            renderSize = CGSize(width: renderSize.height, height: renderSize.width)
        }

        let scale = fmin(renderSize.width / outputFrame.width, renderSize.height / outputFrame.height)*/
        let mixComposition = AVMutableComposition()
        let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        do {
            try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: assetTrack, at: .zero)
        } catch {
            
        }
        if let track = asset.tracks(withMediaType: .audio).first {
            do {
                let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                try audioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: track, at: .zero)
            } catch {
                
            }
        }
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        transform = .identity
        if assetTrack.preferredTransform.b == 1, assetTrack.preferredTransform.c == -1, assetTrack.preferredTransform.tx == 0, assetTrack.preferredTransform.ty == 0 {
            transform = transform.translatedBy(x: assetTrack.naturalSize.height, y: 0)
        } else if assetTrack.preferredTransform.b == -1, assetTrack.preferredTransform.c == 1, assetTrack.preferredTransform.tx == 0, assetTrack.preferredTransform.ty == 0 {
            transform = transform.translatedBy(x: assetTrack.naturalSize.width, y: 0)
        }
        //transform = transform.scaledBy(x: scale, y: scale)
        transform = transform.translatedBy(x: -outputFrame.origin.x, y: -outputFrame.origin.y)
        layerInstruction.setTransform(assetTrack.preferredTransform.concatenating(transform), at: .zero)
        layerInstruction.setOpacity(1.0, at: .zero)
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        mainInstruction.layerInstructions = [layerInstruction]

        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTime(seconds: 1, preferredTimescale: 30)
        mainComposition.renderSize = renderSize

        try? FileManager.default.removeItem(at: outputURL)
        if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.videoComposition = mainComposition
            exportSession.timeRange = CMTimeRange(start: CMTimeMakeWithSeconds(startTime, preferredTimescale: asset.duration.timescale), end: CMTimeMakeWithSeconds(endTime, preferredTimescale: asset.duration.timescale))
            exportSession.exportAsynchronously {
                DispatchQueue.main.async {
                    if let error = exportSession.error {
                        completion(false, nil, error)
                    } else {
                        completion(true, exportSession.outputURL, nil)
                    }
                }
            }
        } else {
            completion(false, nil, nil)
        }
    }
    
    func saveVideo(_ videoURL: URL, completion: @escaping CompleteHandler) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }, completionHandler: { (success, error) in
            if success {
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                if let asset = PHAsset.fetchAssets(with: .video, options: options).lastObject {
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, info) in
                        DispatchQueue.main.async {
                            if let asset = asset as? AVURLAsset {
                                completion(true, asset.url, nil)
                            } else {
                                completion(false, nil, nil)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, nil, nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, nil)
                }
            }
        })
    }
    
    func loadMediaImage(_ identifier: String, _ completion: @escaping (_ image: UIImage?) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: options).firstObject {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { (image, info) in
                completion(image)
            }
        }
    }
}
