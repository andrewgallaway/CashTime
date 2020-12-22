//
//  MediaVC.swift
//  Zoot
//
//  Created by LoveMobile on 9/8/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import Mantis
import MobileCoreServices
import FirebaseStorage
import FirebaseAuth
import SVProgressHUD

class MediaVC: UIViewController {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var longpressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    private var snapshotView: UIView?
    private var snapshotIndexPath: IndexPath?
    private var snapshotPanPoint: CGPoint?
    private var replaceIndex = -1
    fileprivate var arrayPhotos: [Any] = []
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initUI()
        addGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func initUI() {
        //continueButton.layer.borderColor = UIColor.white.cgColor
        progressView.progress = 0.8
    }
    
    func addGestures(){
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(reorderAction))
        longGesture.numberOfTapsRequired = 1
        self.longpressLabel.isUserInteractionEnabled = true
        self.longpressLabel.addGestureRecognizer(longGesture)
    }
    
    func gotoHomeScreen() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MoveAndZoomVC" {
            let controller = segue.destination as! MoveAndZoomVC
            if let image = sender as? UIImage {
                controller.image = image
            } else {
                controller.videoURL = sender as? URL
            }
            controller.delegate = self
        }
    }
    
    // MARK: - IBAction
    @objc @IBAction func nextAction() {
        if arrayPhotos.count == 0 {
            gotoHomeScreen()
            return
        }
        var uploadedCount = 0
        let uid = Auth.auth().currentUser!.uid
        SVProgressHUD.show()
        for media in arrayPhotos {
            if let image = media as? UIImage {
                let data = image.jpegData(compressionQuality: 0.8)!
                let filename = generateRandomFileName(fileExtension: "jpg")
                let storage = Storage.storage().reference(withPath: "\(uid)/profiles/\(filename)")
                storage.putData(data, metadata: nil) { (metaData, error) in
                    uploadedCount += 1
                    if uploadedCount == self.arrayPhotos.count {
                        SVProgressHUD.dismiss()
                        self.gotoHomeScreen()
                    }
                }
            } else if let file = media as? URL {
                let filename = file.lastPathComponent
                let storage = Storage.storage().reference(withPath: "\(uid)/profiles/\(filename)")
                let data = try! Data(contentsOf: file)
                storage.putData(data, metadata: nil) { (metaData, error) in
                    uploadedCount += 1
                    if uploadedCount == self.arrayPhotos.count {
                        SVProgressHUD.dismiss()
                        self.gotoHomeScreen()
                    }
                }
            }
        }
    }
    
    @objc @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func reorderAction() {
        print("reorder reorder")
    }
    
    //Select Photo_Dialog
    func selectPhoto(index: Int) {
        let alert = UIAlertController(title: "Choose Media", message: nil, preferredStyle: .actionSheet)
        /*alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.selectedIndex = index
            self.openCamera()
        }))*/
        
        alert.addAction(UIAlertAction(title: "Pictures", style: .default, handler: { _ in
            self.selectedIndex = index
            self.openPhotoLibrary(mediaType: kUTTypeImage as String)
        }))
        
        alert.addAction(UIAlertAction(title: "Videos", style: .default, handler: { _ in
            self.selectedIndex = index
            self.openPhotoLibrary(mediaType: kUTTypeMovie as String)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You can't use the camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary(mediaType: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [mediaType]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIGestureRecognizer Handlers
    @IBAction func handleLongPressGesture(_ recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: photoCollectionView)
        guard let indexPath = photoCollectionView.indexPathForItem(at: location) else {
            return
        }
        guard let selectedCell = photoCollectionView.cellForItem(at: indexPath) else {
            return
        }
        
        switch recognizer.state {
        case .began:
            if indexPath.item >= arrayPhotos.count { return }
            
            let cell = photoCollectionView.cellForItem(at: indexPath)!
            snapshotView = cell.snapshotView(afterScreenUpdates: true)
            photoCollectionView.addSubview(snapshotView!)
            snapshotView?.center = location
            cell.contentView.alpha = 0.0
            
            UIView.animate(withDuration: 0.2, animations: {
                self.snapshotView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.snapshotView?.alpha = 0.9
            })
            
            snapshotPanPoint = location
            snapshotIndexPath = indexPath
        case .changed:
            guard let snapshotPanPoint = snapshotPanPoint else { return }
            
            let translation = CGPoint(x: location.x - snapshotPanPoint.x, y: location.y - snapshotPanPoint.y)
            snapshotView?.center.x += translation.x
            snapshotView?.center.y += translation.y
            self.snapshotPanPoint = location
            
            if indexPath.item >= arrayPhotos.count { return }
            
            let snapMedia = arrayPhotos[snapshotIndexPath!.item]
            if let index = arrayPhotos.firstIndex(where: { (object) -> Bool in
                if let media = snapMedia as? UIImage, let image = object as? UIImage, media == image {
                    return true
                }
                if let media = snapMedia as? URL, let url = object as? URL, media == url {
                    return true
                }
                return false
            }) {
                arrayPhotos.remove(at: index)
                arrayPhotos.insert(snapMedia, at: indexPath.item)
            }
            
            photoCollectionView.moveItem(at: snapshotIndexPath!, to: indexPath)
            snapshotIndexPath = indexPath
        default:
            guard let snapshotIndexPath = snapshotIndexPath else { return }
            if snapshotIndexPath.item >= arrayPhotos.count { return }
            
            let cell = photoCollectionView.cellForItem(at: snapshotIndexPath)!
            UIView.animate(
                withDuration: 0.1,
                animations: {
                    self.snapshotView?.center = cell.center
                    self.snapshotView?.transform = CGAffineTransform.identity
                    self.snapshotView?.alpha = 1.0
            },
                completion: { finished in
                    cell.contentView.alpha = 1.0
                    self.snapshotView?.removeFromSuperview()
                    self.snapshotView = nil
            })
            self.snapshotIndexPath = nil
            self.snapshotPanPoint = nil
            self.photoCollectionView.reloadData()
        }
    }
}

extension MediaVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var selectedImage: UIImage?
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            performSegue(withIdentifier: "MoveAndZoomVC", sender: selectedImage)
        } else if let url = info[.mediaURL] as? URL {
            print(url)
            performSegue(withIdentifier: "MoveAndZoomVC", sender: url)
        }
        /*let cropViewController = Mantis.cropViewController(image: selectedImage!)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        present(cropViewController, animated: true)*/
    }
}
extension MediaVC : CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        switch self.selectedIndex {
            case 1:
                break
            case 2:
                break
            case 3:
                break
            case 4:
                break
            case 5:
                break
            case 6:
                break
            default:
                
                break
        }
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
         cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension MediaVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionCell
        cell.delegate = self
        if arrayPhotos.count > indexPath.item {
            if let photo = arrayPhotos[indexPath.item] as? UIImage {
                cell.photo = photo
            } else if let url = arrayPhotos[indexPath.item] as? URL {
                cell.video = url
            }
        } else {
            cell.photo = nil
        }
        cell.index = indexPath.item
        return cell
    }
}

extension MediaVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if arrayPhotos.count > indexPath.item {
            return
        }
        selectedIndex = indexPath.item
        selectPhoto(index: selectedIndex)
    }
}

extension MediaVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 8 * 2.0) / 3.0
        let height = (collectionView.frame.height - 8 * 2.0) / 3.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
}

extension MediaVC: PhotoCollectionCellDelegate {
    func didRemovePhoto(_ cell: PhotoCollectionCell) {
        arrayPhotos.remove(at: cell.index)
        photoCollectionView.reloadData()
    }
}

extension MediaVC: MoveAndZoomVCDelegate {
    func didCropImage(_ image: UIImage) {
        arrayPhotos.append(image)
        photoCollectionView.reloadData()
    }
    
    func didCropTrimVideo(_ url: URL) {
        arrayPhotos.append(url)
        photoCollectionView.reloadData()
    }
}
