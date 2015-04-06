//
//  ProfileEditViewController.m
//  Gosu
//
//  Created by dragon on 6/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "User+Extra.h"
#import "PFUser+Extra.h"
#import "DataManager.h"
#import <UIImage-Categories/UIImage+Resize.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ProfileEditViewController ()<UIActionSheetDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL viewLoaded_;
}

@property (nonatomic, strong) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *editBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic, strong) UIImage *changedPhoto;
@end

@implementation ProfileEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onEditCancel:)];
    self.doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(onSave:)];
    self.editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit:)];
    
    
    self.navigationItem.rightBarButtonItem = self.editBarButtonItem;
    viewLoaded_ = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!viewLoaded_) {
        User *currentUser = [User currentUser];
        if (![currentUser.passwordReset boolValue]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset Password" message:@"Gosu randomly assigns your first password, you can change it here, or reset your password by email. Password resets by email will clear your credit card information." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            currentUser.passwordReset = @(YES);
            [currentUser.managedObjectContext save:nil];
        }
        
        PFUser *pUser = [PFUser currentUser];
        
        if (pUser)
        {
            [self firstNameTextField].text = [pUser firstName];
            [self lastNameTextField].text = [pUser lastName];
            
            [self loadPhotoFromServer];
        }
        
        viewLoaded_ = YES;
    }
}

- (void) loadPhotoFromServer
{
    PFFile *photo = [[PFUser currentUser] photo];
    
    if (photo && photo.url)
    {
        [self.addPhotoButton setTitle:@"" forState:UIControlStateNormal];
        __weak typeof (self) wself = self;
        [photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            ProfileEditViewController *sself = wself;
            
            if (!sself)
                return;
            
            UIImage *image = [UIImage imageWithData:data];
            
            if (image) {
                [sself.photoImageView setImage:[UIImage imageWithData:data]];
                [sself.addPhotoButton setTitle:@"" forState:UIControlStateNormal];
            } else {
                [sself.photoImageView setImage:[UIImage imageNamed:@"buddy.png"]];
                [sself.addPhotoButton setTitle:@"Add\nPhoto" forState:UIControlStateNormal];
            }
        }];
    }
    else
    {
        [self.addPhotoButton setTitle:@"Add\nPhoto" forState:UIControlStateNormal];
    }
    self.changedPhoto = nil;
}

#pragma mark Actions

- (IBAction)onResetPassword:(id)sender
{
    [SVProgressHUD show];
    [[DataManager manager] resetPasswordForEmail:[PFUser currentUser].email CompletionHandler:^(BOOL success, NSString *errorDesc) {
        [SVProgressHUD dismiss];
        
        if (success) {
            [[[UIAlertView alloc] initWithTitle:@"Password reset email has been sent successfully. Please follow the instruction in the email." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (IBAction)onEditPhoto:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Photo" otherButtonTitles:@"Choose from Library", nil];
    [actionSheet showInView:sender];
}

- (void)onEdit:(id)sender
{
    [self profileView].userInteractionEnabled = YES;
    
    [UIView beginAnimations:nil context:nil];
    [self addPhotoButton].alpha = 1;
    [UIView commitAnimations];
    [self.navigationItem setLeftBarButtonItem:self.cancelBarButtonItem animated:YES];
    [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem animated:YES];
}

- (void)onSave:(id)sender
{
    self.profileView.userInteractionEnabled = NO;
    [UIView beginAnimations:nil context:nil];
    [self addPhotoButton].alpha = 0;
    [UIView commitAnimations];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:self.editBarButtonItem animated:YES];
    
    NSString *firstName = [self firstNameTextField].text;
    NSString *lastName = [self lastNameTextField].text;
    
    PFUser *user = [PFUser currentUser];
    if (!self.changedPhoto &&
        [firstName isEqualToString:user.firstName] &&
        [lastName isEqualToString:user.lastName]) {
        
        //we don't need to sync with the server.
        return;
    }
    
    __weak ProfileEditViewController *wself = self;
    [[DataManager manager] updateUserProfileWithEmail:nil FirstName:firstName LastName:lastName Photo:self.changedPhoto CompletionHandler:^(BOOL success, NSString *errorDesc) {
        
        __strong ProfileEditViewController *sself = wself;
        
        
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"Saved"];
            sself.changedPhoto = nil;
        } else  {
            [SVProgressHUD showErrorWithStatus:errorDesc];
        }
    }];
}

- (void)onEditCancel:(id)sender
{
    [self loadPhotoFromServer];
    self.profileView.userInteractionEnabled = NO;
    [self addPhotoButton].alpha = 0;
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:self.editBarButtonItem animated:YES];
}

#pragma mark UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        
        if (buttonIndex == actionSheet.destructiveButtonIndex)
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        else
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image;
    if ((image = [info objectForKey:UIImagePickerControllerEditedImage]) ||
        (image = [info objectForKey:UIImagePickerControllerOriginalImage]) )
    {
        UIImage *resizedImage = [image resizedImage:CGSizeMake(120, 120) interpolationQuality:kCGInterpolationHigh];
        self.changedPhoto = resizedImage;
        [self photoImageView].image = resizedImage;
        [self.addPhotoButton setTitle:@"" forState:UIControlStateNormal];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
