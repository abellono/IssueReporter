//
//  NJHViewController.m
//  IssueReporter
//
//  Created by Hakon Hanesand on 07/27/2015.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

#import "ABEViewController.h"

@import IssueReporter;

static NSString * const kNJHTableName = @"IssueReporterDemo-Localizable";

@interface ABEViewController ()

@property (weak, nonatomic) IBOutlet UILabel *shakeLabel;

@end

@implementation ABEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shakeLabel.text = NSLocalizedStringFromTableInBundle(self.shakeLabel.text, kNJHTableName, [NSBundle bundleForClass:self.class], nil);
}

- (IBAction)tap:(id)sender {
    [ABEReporter showReporterView];
}

@end
