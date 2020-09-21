//
//  PhotoCollectionCell.swift
//  Zoot
//
//  Created by LoveMobile on 9/21/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

protocol PhotoCollectionCellDelegate {
    func didRemovePhoto(_ cell: PhotoCollectionCell)
}

class PhotoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addView: CardView!
    @IBOutlet weak var deleteButton: UIButton!
    
    public var delegate: PhotoCollectionCellDelegate? = nil
    public var photo: UIImage? {
        didSet {
            photoImageView.image = photo
            if let _ = photo {
                deleteButton.isHidden = false
                addView.isHidden = true
            } else {
                deleteButton.isHidden = true
                addView.isHidden = false
            }
        }
    }
    public var index: Int = -1
    
    // MARK: - IBAction
    @IBAction func deleteAction(_ sender: UIButton?) {
        delegate?.didRemovePhoto(self)
    }
}
