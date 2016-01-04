//
//  NJHReporterViewController.m
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

// View Controllers
#import "NJHReporterViewController.h"

// Model
#import "NJHIssue.h"

// Helpers
#import "NJHGithubAPIClient.h"
#import "NJHImgurAPIClient.h"
#import "NJHReporter.h"
#import "ABEIssueManager.h"

// Categories
#import "UIBarButtonItem+NJH_CustomBarButton.h"
#import "UIColor+NJH_Color.h"
#import "NSFileManager+NJHFileManager.h"
#import "NSBundle+ABEBundle.h"
#import "UIAlertController+ABEErrorAlertController.h"

static NSString * const kNJHTableName = @"IssueReporter-Localizable";

static NSString * const kNJHPlaceHolderString = @"What went wrong?";
static NSString * const kNJHTitle =             @"New issue";
static NSString * const kSaveImageName =        @"save";

static int const kNJHdescriptionTextViewCornerRadius   = 4;
static double const kNJHdescriptionTextViewBorderWidth = 0.5;

static CGFloat const kNJHTextFieldInset = 14;

static void *ABEImageUploadCountObservingContext = &ABEImageUploadCountObservingContext;

@interface NJHReporterViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UILabel *placeHolderLabel;

@property (nonatomic, weak) NJHImageCollectionViewController *imageCollectionViewController;
@property (nonatomic) ABEIssueManager *issueManager;
@end

@implementation NJHReporterViewController

+ (instancetype)instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:[NSBundle abe_bundleForLibrary]];
    NJHReporterViewController *reporterViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return reporterViewController;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _issueManager = [[ABEIssueManager alloc] initWithReferenceView:[self snapshotCurrentViewState] viewController:self];

        self.title = kNJHTitle;
    }
    
    return self;
}

- (UIView *)snapshotCurrentViewState {
    UIWindow *windowView = [UIApplication sharedApplication].delegate.window;
    return [windowView snapshotViewAfterScreenUpdates:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureBlueBar];
    [self configureTextViews];
    [self setupLocalization];
    
    [self.titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem njh_backButtonWithTarget:self andColor:[UIColor whiteColor] action:@selector(dismissIssueReporter)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem njh_saveButtonWithTarget:self action:@selector(saveIssue)];
    
    [self.issueManager addObserver:self forKeyPath:NSStringFromSelector(@selector(imagesToUpload)) options:NSKeyValueObservingOptionInitial context:ABEImageUploadCountObservingContext];
}

- (void)dealloc {
    [self.issueManager removeObserver:self forKeyPath:NSStringFromSelector(@selector(imagesToUpload)) context:ABEImageUploadCountObservingContext];
}

/**
 *  Adds a spacer on the left side of the top text field and adds a border around the text view
 */
- (void)configureTextViews {
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNJHTextFieldInset, kNJHTextFieldInset)];
    self.titleTextField.leftViewMode = UITextFieldViewModeAlways;
    self.titleTextField.leftView = spacerView;
    
    self.descriptionTextView.layer.borderColor = [UIColor njh_greyBorderColor].CGColor;
    self.descriptionTextView.layer.cornerRadius = kNJHdescriptionTextViewCornerRadius;
    self.descriptionTextView.layer.borderWidth = kNJHdescriptionTextViewBorderWidth;
    self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(kNJHTextFieldInset, kNJHTextFieldInset, 0, kNJHTextFieldInset);
}

- (void)configureBlueBar {
    self.navigationController.navigationBar.barTintColor = [UIColor njh_blueNavigationBarColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)setupLocalization {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    
    self.titleTextField.text = NSLocalizedStringFromTableInBundle(self.titleTextField.text, kNJHTableName, bundle, nil);
    self.placeHolderLabel.text = NSLocalizedStringFromTableInBundle(self.placeHolderLabel.text, kNJHTableName, bundle, nil);
    self.title = NSLocalizedStringFromTableInBundle(self.title, kNJHTableName, bundle, nil);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == ABEImageUploadCountObservingContext) {
        if (self.issueManager.imagesToUpload.count == 0) {
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem njh_saveButtonWithTarget:self action:@selector(saveIssue)];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [spinner startAnimating];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}

- (void)dismissIssueReporter {
    [NSFileManager njh_clearDocumentsDirectory];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (void)saveIssue {
    __weak typeof(self) _self_weak = self;
    [self.issueManager saveIssueWithCompletion:^{
        __strong typeof(self) self = _self_weak;
        [self userDidTryToHideKeyboard:nil]; // animate the keyboard away
        [self dismissIssueReporter];
    }];
}

- (IBAction)userDidTryToHideKeyboard:(id)sender {
    [self.view endEditing:false];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embed_segue"]) {
        self.imageCollectionViewController = segue.destinationViewController;
        self.imageCollectionViewController.issueManager = self.issueManager;
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == self.titleTextField) {
        self.issueManager.issue.title = textField.text;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.descriptionTextView) {
        self.placeHolderLabel.hidden = ![textView.text isEqualToString:@""];
        self.issueManager.issue.issueDescription = textView.text;
    }
}

@end
