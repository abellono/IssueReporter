//
//  ABEReporterViewController.m
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

// View Controllers
#import "ABEReporterViewController.h"

// Model
#import "ABEIssue.h"

// Helpers
#import "ABEGithubAPIClient.h"
#import "ABEImgurAPIClient.h"
#import "ABEReporter.h"
#import "ABEIssueManager.h"

// Categories
#import "UIBarButtonItem+ABECustomBarButton.h"
#import "UIColor+ABEColor.h"
#import "NSFileManager+ABEFileManager.h"
#import "NSBundle+ABEBundle.h"
#import "UIAlertController+ABEErrorAlertController.h"
#import "NSThread+ABEMainThreadRunner.h"

static NSString * const kABETableName = @"IssueReporter-Localizable";

static NSString * const kABEPlaceHolderString = @"What went wrong?";
static NSString * const kABETitle =             @"New issue";
static NSString * const kSaveImageName =        @"save";

static int const kABEdescriptionTextViewCornerRadius   = 4;
static double const kABEdescriptionTextViewBorderWidth = 0.5;

static CGFloat const kABETextFieldInset = 14;

static void *ABEImageUploadCountObservingContext = &ABEImageUploadCountObservingContext;

@interface ABEReporterViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UILabel *placeHolderLabel;

@property (nonatomic, weak) ABEImageCollectionViewController *imageCollectionViewController;
@property (nonatomic) ABEIssueManager *issueManager;
@end

@implementation ABEReporterViewController

+ (instancetype)instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:[NSBundle abe_bundleForLibrary]];
    ABEReporterViewController *reporterViewController = [storyboard instantiateInitialViewController];
    return reporterViewController;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.title = kABETitle;
    }
    
    return self;
}

- (UIView *)snapshotCurrentViewState {
    return [UIApplication sharedApplication].delegate.window;
}

- (void)loadView {
    [super loadView];
    
    self.issueManager = [[ABEIssueManager alloc] initWithReferenceView:[self snapshotCurrentViewState] viewController:self];
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
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kABETextFieldInset, kABETextFieldInset)];
    self.titleTextField.leftViewMode = UITextFieldViewModeAlways;
    self.titleTextField.leftView = spacerView;
    
    self.descriptionTextView.layer.borderColor = [UIColor njh_greyBorderColor].CGColor;
    self.descriptionTextView.layer.cornerRadius = kABEdescriptionTextViewCornerRadius;
    self.descriptionTextView.layer.borderWidth = kABEdescriptionTextViewBorderWidth;
    self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(kABETextFieldInset, kABETextFieldInset, 0, kABETextFieldInset);
}

- (void)configureBlueBar {
    self.navigationController.navigationBar.barTintColor = [UIColor njh_blueNavigationBarColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)setupLocalization {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    
    self.titleTextField.text = NSLocalizedStringFromTableInBundle(self.titleTextField.text, kABETableName, bundle, nil);
    self.placeHolderLabel.text = NSLocalizedStringFromTableInBundle(self.placeHolderLabel.text, kABETableName, bundle, nil);
    self.title = NSLocalizedStringFromTableInBundle(self.title, kABETableName, bundle, nil);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == ABEImageUploadCountObservingContext) {
        [NSThread abe_guaranteeBlockExecutionOnMainThread:^{
            if (self.issueManager.imagesToUpload.count == 0) {
                self.navigationItem.rightBarButtonItem = [UIBarButtonItem njh_saveButtonWithTarget:self action:@selector(saveIssue)];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            } else {
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [spinner startAnimating];
                
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }
        }];
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
