//
//  IssueImage.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/15/16.
//
//

import Foundation

internal enum State {

    case initial
    case saved
    case uploading
    case errored
    case done
}

internal class IssueImage {
    
    let image: UIImage
    let identifier: String = UUID().uuidString
    
    let compressionRatio: Double = 0.5
    
    var localImageURL: URL? = nil {
        didSet {
            self.state.contents = .saved
        }
    }
    
    var cloudImageURL: URL? = nil {
        didSet {
            self.state.contents = .done
        }
    }
    
    var state: Threadsafe<State> = Threadsafe(.initial)
    var compressionCompletionBlock: Threadsafe<((IssueImage) -> ())?> = Threadsafe(nil)
    
    init(image: UIImage) {
        self.image = image.applyRotationToImageData()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            self.imageData = UIImageJPEGRepresentation(self.image, CGFloat(self.compressionRatio))
        }
    }
    
    var imageData: Data? {
        didSet {
            self.compressionCompletionBlock.contents?(self)
        }
    }
}

extension IssueImage: Equatable {
    
    public static func ==(lhs: IssueImage, rhs: IssueImage) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
