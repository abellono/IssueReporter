//
//  ABEImageCollectionViewCell.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/7/16.
//
//

import Foundation
import UIKit

internal class ABEImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var blurEffectView: UIVisualEffectView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
        layer.borderColor = UIColor.red.withAlphaComponent(0.5).cgColor
    }

    var didErrorDuringUpload: Bool = false {
        didSet {
            if didErrorDuringUpload {
                UIView.animate(withDuration: 0.3, animations: { 
                    self.blurEffectView.isHidden = false
                    self.layer.borderWidth = 1
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.blurEffectView.isHidden = true
                    self.layer.borderWidth = 0
                })
            }
        }
    }
}
