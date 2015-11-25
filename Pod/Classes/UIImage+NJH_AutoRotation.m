//
//  UIImage+AutoRotation.m
//  IssueReporter
//
//  Created by Hakon Hanesand on 7/24/15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "UIImage+NJH_AutoRotation.h"

@implementation UIImage (NJH_AutoRotation)

// http://stackoverflow.com/a/21586796/4080860
- (UIImage *)njh_rotateImageInPreparationForDataConversion {
    if(!(self.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationUpMirrored)) {
        CGSize imgsize = self.size;
        UIGraphicsBeginImageContext(imgsize);
        [self drawInRect:CGRectMake(0.0, 0.0, imgsize.width, imgsize.height)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return self;
}

@end
