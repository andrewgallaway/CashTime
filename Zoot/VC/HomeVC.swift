//
//  HomeVC.swift
//  Zoot
//
//  Created by WMaster on 10/20/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import TwilioVideo
import SnapKit

class HomeVC: UIViewController {

    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var gemsView: UIView!
    @IBOutlet weak var gemsLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var usersTableView: UITableView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var roomTextView: UIView!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var recentView: UIView!
    
    fileprivate var previewView: VideoView!
    fileprivate var camera: CameraSource?
    fileprivate var localVideoTrack: LocalVideoTrack?
    fileprivate var localAudioTrack: LocalAudioTrack?
    fileprivate var remoteParticipant: RemoteParticipant?
    fileprivate var remoteView: VideoView?
    
    fileprivate var querySnapshot: QuerySnapshot!
    fileprivate var queryDocuments: [QueryDocumentSnapshot] = []
    fileprivate var searchedDocuments: [QueryDocumentSnapshot] = []
    
    deinit {
        // We are done with camera
        if let camera = self.camera {
            camera.stopCapture()
            self.camera = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let _ = Auth.auth().currentUser else {
            showLoginScreen(false)
            return
        }
        
        if Auth.auth().currentUser != nil, previewView == nil, !PlatformUtils.isSimulator {
            setupPreviewView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        removePreviewView()
    }
    
    func showLoginScreen(_ animation: Bool) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! UINavigationController
        //let controller = storyboard.instantiateInitialViewController() as! UIViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: animation, completion: nil)
    }
    
    func loadUsers() {
        Firestore.firestore().collection("users").getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                self.querySnapshot = snapshot
                self.queryDocuments = snapshot.documents
                self.searchUsers(self.searchTextField.text!)
            }
        }
    }
    
    func searchUsers(_ searchKey: String) {
        searchedDocuments = queryDocuments.filter({ (snapshot) -> Bool in
            let user = snapshot.data()
            let name = user["name"] as! String
            return name.lowercased().contains(searchKey.lowercased())
        })
        usersTableView.reloadData()
    }
    
    func setupPreviewView() {
        previewView = VideoView(frame: .zero, delegate: self)
        previewView.contentMode = .scaleAspectFill
        videoView.insertSubview(previewView, at: 0)
        previewView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let frontCamera = CameraSource.captureDevice(position: .front)
        let backCamera = CameraSource.captureDevice(position: .back)

        if frontCamera != nil || backCamera != nil {

            let options = CameraSourceOptions { (builder) in
                if #available(iOS 13.0, *) {
                    // Track UIWindowScene events for the key window's scene.
                    // The example app disables multi-window support in the .plist (see UIApplicationSceneManifestKey).
                    builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)
                }
            }
            // Preview our local camera track in the local video preview view.
            camera = CameraSource(options: options, delegate: self)
            localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")

            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(self.previewView)

            if (frontCamera != nil && backCamera != nil) {
                // We will flip camera on tap.
                let tap = UITapGestureRecognizer(target: self, action: #selector(HomeVC.flipCamera))
                self.previewView.addGestureRecognizer(tap)
            }

            camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.previewView.shouldMirror = (captureDevice.position == .front)
                }
            }
        } else {
            print("No front or back capture device found!")
        }
    }
    
    func removePreviewView() {
        if let camera = self.camera {
            camera.stopCapture()
            self.camera = nil
        }
        
        if let videoTrack = localVideoTrack {
            videoTrack.removeRenderer(previewView)
            self.localVideoTrack = nil
        }
        
        if previewView != nil {
            previewView.removeFromSuperview()
        }
        previewView = nil
    }
    
    @objc func flipCamera() {
        var newDevice: AVCaptureDevice?

        if let camera = self.camera, let captureDevice = camera.device {
            if captureDevice.position == .front {
                newDevice = CameraSource.captureDevice(position: .back)
            } else {
                newDevice = CameraSource.captureDevice(position: .front)
            }

            if let newDevice = newDevice {
                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
                    if let error = error {
                        print("Error selecting capture device.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                    } else {
                        self.previewView.shouldMirror = (captureDevice.position == .front)
                    }
                }
            }
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
    @IBAction func signoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            showLoginScreen(true)
        } catch {
            
        }
    }
    
    @IBAction func profileAction(_ sender: UIButton) {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "ProfileNavigationVC") as! UINavigationController
        let controller = navigationController.viewControllers.first as! ProfileVC
        controller.userId = nil
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func searchAction(_ sender: UIButton) {
        searchButton.isHidden = true
        profileButton.isHidden = true
        gemsView.isHidden = true
        searchView.isHidden = false
        logoImageView.isHidden = true
        roomTextView.isHidden = true
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func searchCancelAction(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        searchButton.isHidden = false
        profileButton.isHidden = false
        gemsView.isHidden = false
        searchView.isHidden = true
        logoImageView.isHidden = false
        roomTextView.isHidden = false
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedDocuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! UserTableCell
        let document = searchedDocuments[indexPath.row]
        cell.user = document.data()
        cell.userId = document.documentID
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! UserTableCell
        didTapProfile(cell: cell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK:- VideoViewDelegate
extension HomeVC: VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK:- CameraSourceDelegate
extension HomeVC : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        print("Camera source failed with error: \(error.localizedDescription)")
    }
}

// MARK: - UITextFieldDelegate
extension HomeVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        searchUsers(newText)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //searchUsers(textField.text!)
        return true
    }
}

// MARK: - UserTableCellDelegate
extension HomeVC: UserTableCellDelegate {
    func didTapProfile(cell: UserTableCell) {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "ProfileNavigationVC") as! UINavigationController
        let controller = navigationController.viewControllers.first as! ProfileVC
        navigationController.modalPresentationStyle = .fullScreen
        controller.userId = cell.userId
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func didTapCall(cell: UserTableCell) {
        
    }
}
