//
//  SignInVC.swift
//  Zoot
//
//  Created by LoveMobile on 8/24/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import AuthenticationServices
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import InstagramLogin

class SignInVC: UIViewController {

    @IBOutlet weak var phoneNumberSignInView: CardView!
    @IBOutlet weak var facebookSignInView: CardBorderView!
    @IBOutlet weak var googleSignInView: CardBorderView!
    @IBOutlet weak var instagramSignInView: CardBorderView!
        
    @IBOutlet weak var appleSignInView: UIStackView!
    
    var instagramLogin: InstagramLoginViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        add_Gestures()
        // Do any additional setup after loading the view.
    }
    
    func initUI(){
        let button = ASAuthorizationAppleIDButton()
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(apple_SignInAction), for: .touchUpInside)
        self.appleSignInView.addArrangedSubview(button)
        
        GIDSignIn.sharedInstance()?.delegate = self
        
    }
    
    func add_Gestures(){
        let phone_gesture = UITapGestureRecognizer(target: self, action: #selector(phone_SignInAction))
        self.phoneNumberSignInView.isUserInteractionEnabled = true
        self.phoneNumberSignInView.addGestureRecognizer(phone_gesture)
       
        let fb_gesture = UITapGestureRecognizer(target: self, action: #selector(fb_SignInAction))
        self.facebookSignInView.isUserInteractionEnabled = true
        self.facebookSignInView.addGestureRecognizer(fb_gesture)
        
        let google_gesture = UITapGestureRecognizer(target: self, action: #selector(google_SignInAction))
        self.googleSignInView.isUserInteractionEnabled = true
        self.googleSignInView.addGestureRecognizer(google_gesture)
        
        let instagram_gesture = UITapGestureRecognizer(target: self, action: #selector(instagram_SignInAction))
        self.instagramSignInView.isUserInteractionEnabled = true
        self.instagramSignInView.addGestureRecognizer(instagram_gesture)
    }
    
    @objc func phone_SignInAction(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PhoneVC") as! PhoneVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func apple_SignInAction(){
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    @objc func fb_SignInAction(){
        let fbLoinManager : LoginManager = LoginManager()
        fbLoinManager.logIn(permissions: ["email"], from: self){
            (result, error) in
            if (error == nil){
                let fbLoginResult : LoginManagerLoginResult = result!
                if fbLoginResult.grantedPermissions != nil {
                    if (fbLoginResult.grantedPermissions.contains("email")){
                        if((AccessToken.current) != nil){
                            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email,birthday "]).start(completionHandler: { (connection, result, error) -> Void in
                                if (error == nil){
                                    print(result)
                                    
                                    //Go to Next Action...
                                }
                            })
                        }
                        
                    }
                }
            }
        }
    }
    
    @objc func google_SignInAction(){
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @objc func instagram_SignInAction(){
        instagramLogin = InstagramLoginViewController(clientId: "1464a5cef63d4287bd4cb21e0498b1c7", redirectUri: "http://mcflydelivery.com")
        instagramLogin.delegate = self
        instagramLogin.scopes = [.basic, .publicContent]
        instagramLogin.title = "Instagram"
        instagramLogin.progressViewTintColor = .blue
        instagramLogin.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissLoginViewController))
        instagramLogin.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshPage))
        present(UINavigationController(rootViewController: instagramLogin), animated: true)
        
    }
    @objc func dismissLoginViewController() {
           instagramLogin.dismiss(animated: true)
       }
       
       @objc func refreshPage() {
           instagramLogin.reloadPage()
       }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
}

extension SignInVC : GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
               print(error.localizedDescription)
               self.showAlert("Google Authentication Failed.")
               return
        }
        
        //Go to Next action....
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "birthdateVC") as! BirthdateVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "SignIn Process", message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension SignInVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            case let credential as ASAuthorizationAppleIDCredential:
                let userId = credential.user
                print("User Identifier: ", userId)
                
                if let fullname = credential.fullName {
                    print(fullname)
                }
                
                if let email = credential.email {
                    print("Email: ", email)
                }
                break
            default:
            break
        }
    }
}

extension SignInVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension SignInVC: InstagramLoginViewControllerDelegate {
    func instagramLoginDidFinish(accessToken: String?, error: InstagramError?) {
        if(error != nil){
            return
        }
        print(accessToken)
    }
    func getUserInstarInfo(token : String){
        
    }
}
