//
//  MoveAndZoomVc.swift
//  DemoAdam
//
//  Created by mac on 10/09/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit

class MoveAndZoomVc: UIViewController , UIScrollViewDelegate {
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var scrollView: FAScrollView!
    
    private var croppedImage: UIImage? = nil
    private var isFirstLayout = true
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstLayout {
            isFirstLayout = false
            scrollView.layoutIfNeeded()
            self.scrollView.imageToDisplay = image
            scrollView.zoom()
            scrollView.updateLayout()
        }
    }

    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showTapped(_ sender: Any) {
        
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "ImageDetailVc") as! ImageDetailVc
        vc.image = captureVisibleRect()
      
        self.navigationController?.pushViewController(vc, animated: true)
    }
  
    private func captureVisibleRect() -> UIImage{
        
        var croprect = CGRect.zero
        let xOffset = (scrollView.imageToDisplay?.size.width)! / scrollView.contentSize.width;
        let yOffset = (scrollView.imageToDisplay?.size.height)! / scrollView.contentSize.height;
        
        croprect.origin.x = scrollView.contentOffset.x * xOffset;
        croprect.origin.y = scrollView.contentOffset.y * yOffset;
        
        let normalizedWidth = (scrollView?.frame.width)! / (scrollView?.contentSize.width)!
        let normalizedHeight = (scrollView?.frame.height)! / (scrollView?.contentSize.height)!
        
        croprect.size.width = scrollView.imageToDisplay!.size.width * normalizedWidth
        croprect.size.height = scrollView.imageToDisplay!.size.height * normalizedHeight
        
        let toCropImage = scrollView.imageView.image?.fixImageOrientation()
        let cr: CGImage? = toCropImage?.cgImage?.cropping(to: croprect)
        let cropped = UIImage(cgImage: cr!)
        
        return cropped
    }
}



