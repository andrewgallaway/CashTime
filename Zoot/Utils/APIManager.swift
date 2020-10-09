//
//  APIManager.swift
//  Zoot
//
//  Created by LoveMobile on 9/29/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import Alamofire

let SERVER_LINK = "http://localhost:3000/"
let SERVER_MAIN = "http://localhost:3000/"
//let SERVER_LINK = "https://www.cashtime.com/"
//let SERVER_MAIN = "https://www.cashtime.com/"

class APIManager: NSObject {
    static let shared = APIManager()
    
    private var cookies: [HTTPCookie]? = nil
    public var header: String? = nil
    
    private func post(_ url: String, _ params: [String : Any]) -> DataRequest {
        if let header = self.header {
            return AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Cookie" : header])
        } else {
            return AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    private func get(_ url: String, _ params: [String : Any]) -> DataRequest {
        if let header = self.header {
            return AF.request(url, method: .get, parameters: params, headers: ["Cookie" : header])
        } else {
            return AF.request(url, method: .get, parameters: params)
        }
    }
    
    private func put(_ url: String, _ params: [String : Any]) -> DataRequest {
        if let header = self.header {
            return AF.request(url, method: .put, parameters: params, headers: ["Cookie" : header])
        } else {
            return AF.request(url, method: .put, parameters: params)
        }
    }
    
    private func delete(_ url: String, _ params: [String : Any]) -> DataRequest {
        if let header = self.header {
            return AF.request(url, method: .delete, parameters: params, headers: ["Cookie" : header])
        } else {
            return AF.request(url, method: .delete, parameters: params)
        }
    }
    
    func cancelAllRequests() {
        AF.cancelAllRequests()
    }
    
    func signin(_ email: String, _ password: String, _ completion: @escaping (_ response: [String : Any]?, _ error: Error?) -> Void) {
        let params = ["email" : email,
                      "password" : password]
        get(SERVER_LINK + "users/signin", params).responseJSON { (response) in
            switch response.result {
            case .success(let result):
                //print(result)
                if let header = response.response?.allHeaderFields {
                    //print(header)
                    if let cookie = header["Set-Cookie"] as? String {
                        self.header = cookie.components(separatedBy: ";").first!
                    }
                    self.cookies = HTTPCookie.cookies(withResponseHeaderFields: header as! [String : String], for: URL(string: SERVER_MAIN)!)
                }
                if let result = result as? [String : Any] {
                    if let status = result["status"] as? Bool {
                        if status == true {
                            completion(result["data"] as? [String : Any], nil)
                        } else {
                            let data = result["data"] as! [String : String]
                            let userInfo = [NSLocalizedDescriptionKey : data["error"]!]
                            completion(nil, NSError(domain: "BranchVideoSigninErrorDomain", code: 30001, userInfo: userInfo))
                        }
                    }
                } else {
                    completion(nil, nil)
                }
                break
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
    
    func isExistEmail(_ email: String, _ completion: @escaping (_ response: [String : Any]?, _ error: Error?) -> Void) {
        let params = ["email" : email]
        get(SERVER_LINK + "users/is_exist_email", params).responseJSON { (response) in
            switch response.result {
            case .success(let result):
                if let result = result as? [String : Any], let status = result["status"] as? Bool, status == true {
                    completion(result["data"] as? [String : Any], nil)
                } else {
                    completion(nil, nil)
                }
                break
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
    
    func isExistUsername(_ username: String, _ completion: @escaping (_ response: [String : Any]?, _ error: Error?) -> Void) {
        let params = ["username" : username]
        get(SERVER_LINK + "users/is_exist_username", params).responseJSON { (response) in
            switch response.result {
            case .success(let result):
                if let result = result as? [String : Any], let status = result["status"] as? Bool, status == true {
                    completion(result["data"] as? [String : Any], nil)
                } else {
                    completion(nil, nil)
                }
                break
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
    
    func signup(_ email: String, username: String, fullname: String, password: String, phone: String, phone_code: String, birthday: Date, _ completion: @escaping (_ response: [String : Any]?, _ error: Error?) -> Void) {
        let params = ["email" : email,
                      "password" : password,
                      "name" : fullname,
                      "username" : username,
                      "phone" : phone,
                      "phone_code" : phone_code,
                      "birthday" : birthday] as [String : Any]
        post(SERVER_LINK + "users/signup", params).responseJSON { (response) in
            switch response.result {
            case .success(let result):
                //print(result)
                if let header = response.response?.allHeaderFields {
                    if let cookie = header["Set-Cookie"] as? String {
                        self.header = cookie.components(separatedBy: ";").first!
                    }
                    self.cookies = HTTPCookie.cookies(withResponseHeaderFields: header as! [String : String], for: URL(string: SERVER_MAIN)!)
                }
                if let result = result as? [String : Any] {
                    if let status = result["status"] as? Bool {
                        if status == true {
                            completion(result["data"] as? [String : Any], nil)
                        } else {
                            let data = result["data"] as! [String : String]
                            let userInfo = [NSLocalizedDescriptionKey : data["error"]!]
                            completion(nil, NSError(domain: "BranchVideoSigninErrorDomain", code: 30001, userInfo: userInfo))
                        }
                    }
                } else {
                    completion(nil, nil)
                }
                break
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
    
    func uploadMedias(_ email: String, _ medias: [CTMedia], _ completion: @escaping (_ response: [String : Any]?, _ error: Error?) -> Void) {
        let params = ["email" : email]
        post(SERVER_LINK + "users/upload_medias", params).responseJSON { (response) in
            switch response.result {
            case .success(let result):
                //print(result)
                if let header = response.response?.allHeaderFields {
                    if let cookie = header["Set-Cookie"] as? String {
                        self.header = cookie.components(separatedBy: ";").first!
                    }
                    self.cookies = HTTPCookie.cookies(withResponseHeaderFields: header as! [String : String], for: URL(string: SERVER_MAIN)!)
                }
                if let result = result as? [String : Any] {
                    if let status = result["status"] as? Bool {
                        if status == true {
                            completion(result["data"] as? [String : Any], nil)
                        } else {
                            let data = result["data"] as! [String : String]
                            let userInfo = [NSLocalizedDescriptionKey : data["error"]!]
                            completion(nil, NSError(domain: "BranchVideoSigninErrorDomain", code: 30001, userInfo: userInfo))
                        }
                    }
                } else {
                    completion(nil, nil)
                }
                break
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
}
