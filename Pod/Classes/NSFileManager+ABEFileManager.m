//
//  NSFileManager+ABEFileManager.m
//  Pods
//
//  Created by Hakon Hanesand on 11/25/15.
//
//

#import "NSFileManager+ABEFileManager.h"

@implementation NSFileManager (ABEFileManager)

+ (void)njh_clearDocumentsDirectory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *directory = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    NSError *error = nil;
    NSDirectoryEnumerationOptions options = NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles;
    
    for (NSURL *file in [fm contentsOfDirectoryAtURL:directory includingPropertiesForKeys:nil options:options error:&error]) {
        BOOL success = [fm removeItemAtURL:file error:&error];
        
        if (!success || error) {
            NSLog(@"unable to delete file at path %@", file);
        }
    }
}

@end
