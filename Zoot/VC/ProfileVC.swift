//
//  ProfileVC.swift
//  Zoot
//
//  Created by WMaster on 11/6/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SDWebImage
import LXPageControl
import GrowingTextView

class ProfileVC: UIViewController {
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var mediasCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: LXPageControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var descriptionoLabel: UILabel!
    @IBOutlet weak var messageTextView: GrowingTextView!
    
    @IBOutlet weak var heightMessageConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightDescriptionConstraint: NSLayoutConstraint!

    fileprivate var medias: [StorageReference] = []
    
    fileprivate let MAX_DESCRIPTION_HEIGHT: CGFloat = 360
    fileprivate let MIN_DESCRIPTION_HEIGHT: CGFloat = 148
    
    public var userId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentScrollView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 13.0, *) {
            contentScrollView.automaticallyAdjustsScrollIndicatorInsets = false
        } else {
            // Fallback on earlier versions
        }
        
        pageControl.activeColor = .white
        pageControl.inactiveColor = UIColor.white.withAlphaComponent(0.6)
        pageControl.spacing = 10
        pageControl.elementHeight = 2
        pageControl.elementWidth = (UIScreen.main.bounds.width - 78.0) / 3.0
        pageControl.cornerRadius = 0
        pageControl.delegate = self
        
        messageTextView.minHeight = 36
        messageTextView.placeholder = "Send Message"
        messageTextView.placeholderColor = .lightGray
        
        loadUserDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func loadUserDetails() {
        var userId = self.userId
        if userId == nil {
            userId = Auth.auth().currentUser!.uid
        }
        
        let document = Firestore.firestore().collection("users").document(userId!)
        document.getDocument(completion: { (document, error) in
            if let document = document?.data() {
                self.nameLabel.text = document["name"] as? String
                self.usernameLabel.text = "@\(document["username"] as! String)"
            }
        })
        loadUserFiles(userId!)
    }
    
    fileprivate func loadUserFiles(_ userId: String) {
        let storage = Storage.storage().reference(withPath: "\(userId)/profiles/")
        storage.list(withMaxResults: 4) { (result, error) in
            self.pageControl.pages = result.items.count
            self.medias = result.items
            self.mediasCollectionView.reloadData()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - IBAction
    @IBAction func backAction(_ sender: UIButton?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreAction(_ sender: UIButton?) {
        performSegue(withIdentifier: "SettingsVC", sender: nil)
    }
    
    @IBAction func videoCallAction(_ sender: UIButton?) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "VideoRoomVC") as! VideoRoomVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handlePanGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: contentScrollView)
        var height = heightDescriptionConstraint.constant - translation.y
        if sender.state == .began || sender.state == .changed {
            heightDescriptionConstraint.constant = height
            self.view.layoutIfNeeded()
        } else {
            var animation = false
            if height > blurView.frame.origin.y + descriptionoLabel.frame.origin.y + descriptionoLabel.frame.height + 24 {
                height = blurView.frame.origin.y + descriptionoLabel.frame.origin.y + descriptionoLabel.frame.height + 24
                animation = true
            } else if height < MIN_DESCRIPTION_HEIGHT {
                height = MIN_DESCRIPTION_HEIGHT
                animation = true
            }
            if animation == false {
                heightDescriptionConstraint.constant = height
                self.view.layoutIfNeeded()
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.heightDescriptionConstraint.constant = height
                    self.view.layoutIfNeeded()
                }
            }
        }
        sender.setTranslation(.zero, in: contentScrollView)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension ProfileVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionCell", for: indexPath) as! MediaCollectionCell
        let media = medias[indexPath.item]
        let fileExtension = URL(string: media.fullPath)!.pathExtension
        media.downloadURL { (url, error) in
            if fileExtension == "jpg" {
                cell.photoURL = url
            } else {
                cell.video = url
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - GrowingTextViewDelegate
extension ProfileVC: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        heightMessageConstraint.constant = 20 + height
    }
}

// MARK: - LXPageControlDelegate
extension ProfileVC: LXPageControlDelegate {
    func pageControl(_ pageControl: LXPageControl, changeProgress to: Int) {
        mediasCollectionView.setContentOffset(CGPoint(x: CGFloat(to) * mediasCollectionView.frame.width, y: 0), animated: true)
    }
    
    func pageControl(_ pageControl: LXPageControl, didPressedOn button: UIButton) {
        
    }
}

// MARK: - UIScrollViewDelegate
extension ProfileVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mediasCollectionView {
            let index = scrollView.contentOffset.x / scrollView.frame.width
            pageControl.currentPage = Int(index)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == mediasCollectionView {
            if decelerate == false {
                let index = scrollView.contentOffset.x / scrollView.frame.width
                pageControl.currentPage = Int(index)
            }
        }
    }
}
