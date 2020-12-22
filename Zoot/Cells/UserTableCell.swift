//
//  UserTableCell.swift
//  Zoot
//
//  Created by WMaster on 11/26/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import AVKit
import FirebaseStorage
import SDWebImage

protocol UserTableCellDelegate {
    func didTapProfile(cell: UserTableCell)
    func didTapCall(cell: UserTableCell)
}

class UserTableCell: UITableViewCell {

    @IBOutlet weak var thumbButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    fileprivate var videoPlayer: AVPlayer? = nil
    fileprivate var playerLayer: AVPlayerLayer? = nil
    fileprivate var playerItem: AVPlayerItem? = nil
    
    public var delegate: UserTableCellDelegate? = nil
    public var user: [String : Any]! {
        didSet {
            usernameLabel.text = user["name"] as? String
        }
    }
    
    public var userId: String! {
        didSet {
            let storage = Storage.storage().reference(withPath: "\(userId!)/profiles/")
            storage.list(withMaxResults: 1) { (result, error) in
                if let item = result.items.first {
                    let fileExtension = URL(string: item.fullPath)!.pathExtension
                    if fileExtension == "jpg" {
                        item.downloadURL { (url, error) in
                            self.thumbButton.sd_setImage(with: url, for: .normal, placeholderImage: UIImage(named: "IconUser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
                        }
                    } else {
                        self.thumbButton.setImage(UIImage(named: "IconUser"), for: .normal)
                    }
                } else {
                    self.thumbButton.setImage(UIImage(named: "IconUser"), for: .normal)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        thumbButton.layer.cornerRadius = thumbButton.frame.size.width / 2.0
        thumbButton.layer.borderWidth = 1.5
        thumbButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
    }

    // MARK: - IBAction
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        delegate?.didTapProfile(cell: self)
    }
    
    @IBAction func callButtonPressed(_ sender: UIButton) {
        delegate?.didTapCall(cell: self)
    }
}
