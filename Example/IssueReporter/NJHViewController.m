//
//  NJHViewController.m
//  IssueReporter
//
//  Created by Hakon Hanesand on 07/27/2015.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

#import "NJHViewController.h"

#import "IssueReporter/NJHReporter.h"

static NSString * const kNJHTableName = @"IssueReporterDemo-Localizable";

@interface NJHViewController ()
@property (weak, nonatomic) IBOutlet UILabel *shakeLabel;
@end

@implementation NJHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shakeLabel.text = NSLocalizedStringFromTableInBundle(self.shakeLabel.text, kNJHTableName, [NSBundle bundleForClass:self.class], nil);
}

- (IBAction)tap:(id)sender {
    [[NJHReporter reporter] showReporterView];
}

@end
