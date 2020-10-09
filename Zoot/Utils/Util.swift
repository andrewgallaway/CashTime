//
//  Util.swift
//  Zoot
//
//  Created by LoveMobile on 8/25/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import Foundation
import UIKit

let VIDEO_EXTENSION = "mov"

func getIFAddresses() -> [String] {
    var addresses = [String]()

    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return [] }
    guard let firstAddr = ifaddr else { return [] }

    // For each interface ...
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        let addr = ptr.pointee.ifa_addr.pointee

        // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
        if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
            if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {

                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                    let address = String(cString: hostname)
                    addresses.append(address)
                }
            }
        }
    }

    freeifaddrs(ifaddr)
    return addresses
}

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func generateRandomFileName(length: Int = 48, fileExtension: String) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyz1234567890"
    let length = letters.count
    var filename = ""
    for _ in 0..<length {
        let rand = arc4random_uniform(UInt32(length))
        let startIndex = letters.index(letters.startIndex, offsetBy: String.IndexDistance(rand))
        let endIndex = letters.index(startIndex, offsetBy: 1)
        filename += letters[startIndex..<endIndex]
    }
    return filename + "." + fileExtension
}

func generateVideoFilePath(filename: String) -> String {
    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/Videos/"
    if FileManager.default.fileExists(atPath: path) == false {
        try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    path = path + filename
    return path
}

func showAlertViewController(title: String? = nil, message: String) {
    let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
        
    }
    controller.addAction(action)
    if let topViewController = UIApplication.topViewController() {
        topViewController.present(controller, animated: true, completion: nil)
    }
}
