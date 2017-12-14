//
//  Image.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation

internal class Image {
    
    let image: UIImage
    let identifier: String = UUID().uuidString
    
    let compressionRatio: Double = 0.5
    
    var localImageURL: URL? = nil    
    var cloudImageURL: URL? = nil
    
    var state: State = .initial
    var compressionCompletionBlock: (Image) -> () = { _ in }
    
    init(image: UIImage) {
        self.image = image.applyRotationToImageData()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.imageData = UIImageJPEGRepresentation(strongSelf.image, CGFloat(strongSelf.compressionRatio))
        }
    }
    
    var imageData: Data? {
        didSet {
            DispatchQueue.main.async {
                self.compressionCompletionBlock(self)
            }
        }
    }
}

extension Image: Equatable {
    
    public static func ==(lhs: Image, rhs: Image) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
