//
//  ProfileViewController.m
//  RBook
//
//  Created by Andola on 16/09/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import "ProfileViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <JGActionSheet/JGActionSheet.h>
#import "RSKImageCropper.h"
#import "Constant.h"
#import "FirebaseManager.h"

@interface ProfileViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, RSKImageCropViewControllerDelegate>
{
    UITextField *currentTxtField;
    NSString *fName;
    NSString *lName;
    NSString *dob;
    NSString *phone;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self designAfterStoryboard];
    
    if (self.isViewProfile) {
        // Get All the Profile data
        
        [[FirebaseManager sharedInstance] downloadImageWithCompleteBlock:^(id object, NSError *error) {
            if (!error) {
                NSURL *url = object;
                [self.imageViewBG sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL *imageurl) {
                    
                    if (image) {
                        self.profileImage = image;
                        [self.btnProfile setBackgroundImage:image forState:UIControlStateNormal];
                    } else {
                        self.profileImage = nil;
                        [self.btnProfile setBackgroundImage:[UIImage imageNamed:@"user.png"] forState:UIControlStateNormal];
                    }
                }];
            }
        }];
        
        [[FirebaseManager sharedInstance] dbReferenceWithChild:@"profile" andSuperChild:kGetUserDefault(@"UserAuth")];
        [[FirebaseManager sharedInstance] retrieveDatawithCompleteBlock:^(id object, NSError *error) {
            if (object) {
                NSDictionary *dictRecipe = (NSDictionary *)object;
                dob = dictRecipe[@"DOB"];
                fName = dictRecipe[@"FirstName"];
                lName = dictRecipe[@"LastName"];
                phone = dictRecipe[@"Phone"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update screen
                    [self.tblProfileData reloadData];
                });
            } 
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Set up

- (void)designAfterStoryboard
{
    self.imageViewBG.alpha = 0.2f;
    
    // Set the cornner radius for the profile pic
    
    self.btnProfile.layer.cornerRadius = self.btnProfile.frame.size.height / 2;
    self.btnProfile.layer.masksToBounds = YES;
    self.btnProfile.backgroundColor = [UIColor whiteColor];    
}

#pragma mark - Button Actions

- (IBAction)btnCloseOnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnProfileOnClicked:(id)sender {
    
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:@"Add Profile Pic" message:nil buttonTitles:@[@"Choose photo", @"Take Photo"] buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleRed];
    
    NSArray *sections = @[section1, cancelSection];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
    
    for (UIButton *button in section1.buttons)
    {
        [button setTitleColor:[UIColor colorWithRed:253.0/255.0 green:78.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    
    for (UIButton *button in cancelSection.buttons)
    {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            // choose photo button tapped.
            [self choosePhoto];
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            // take photo button tapped.
            [self takePhoto];
        }
        
        [sheet dismissAnimated:YES];
    }];
    
    [sheet showInView:self.view animated:YES];
}

- (IBAction)btnDoneOnclicked:(id)sender {
    
    
    
    [currentTxtField resignFirstResponder];
    NSData *imageData = UIImageJPEGRepresentation(self.profileImage, 0.5f);
    if (imageData.length) {
        [[FirebaseManager sharedInstance] uploadImageWithImageData:imageData withCompleteBlock:^(id object, NSError *error) {
            
        }];
    }
    
    NSDictionary *dictProfile = @{
                                  @"FirstName": fName,
                                  @"LastName": lName,
                                  @"Email": kGetUserDefault(@"UserEmail"),
                                  @"DOB": dob,
                                  @"Phone": phone
                                  };
    [[FirebaseManager sharedInstance] dbReferenceWithChild:@"profile" andSuperChild:kGetUserDefault(@"UserAuth")];
    [[FirebaseManager sharedInstance] saveDataWithValue:dictProfile withCompleteBlock:^(id object, NSError *error) {
        
    }];
}

#pragma mark - Get & Set the profile pic

- (void)takePhoto
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        [self openCamera];
    } else if(status == AVAuthorizationStatusDenied){ // denied
        [self showCameraDeniedAlert];
    }
    else if(status == AVAuthorizationStatusRestricted){ // restricted
        [self showCameraDeniedAlert];
    }
    else if(status == AVAuthorizationStatusNotDetermined){ // not determined
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){ // Access has been granted ..do something
                [self openCamera];
            } else {
                [self showCameraDeniedAlert];
            }
        }];
    }
}

- (void)openCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [imagePicker setDelegate:self];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)choosePhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self sendPhotoToCrop:image];
    }];
}

#pragma mark - RSKImageCropViewController

- (void) sendPhotoToCrop:(UIImage *) photo {
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:photo cropMode:RSKImageCropModeCircle];
    imageCropVC.delegate = self;
    [self presentViewController:imageCropVC animated:YES completion:nil];
}

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    self.profileImage = croppedImage;
    [self setTheProfileImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setTheProfileImage
{
    self.imageViewBG.image = self.profileImage;
    [self.btnProfile setBackgroundImage:self.profileImage forState:UIControlStateNormal];
}

#pragma mark - Alert
-(void)showCameraDeniedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Denied Camera Access"
                                                    message:@"RBook does not have access to your photos or videos. To enable acess go to: iPhone Settings > RBook > Camera "
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([indexPath section] == 0) {
        UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, CGRectGetWidth(self.view.frame) - 110 - 8, 30)];
        playerTextField.adjustsFontSizeToFitWidth = YES;
        playerTextField.textColor = [UIColor blackColor];
        
        if ([indexPath row] == 0) {
            playerTextField.tag = 10001;
            playerTextField.placeholder = @"First Name";
            playerTextField.keyboardType = UIKeyboardTypeDefault;
            playerTextField.returnKeyType = UIReturnKeyNext;
            if (fName.length) {
                playerTextField.text = fName;
            }
        }
        else if ([indexPath row] == 1) {
            playerTextField.tag = 10002;
            playerTextField.placeholder = @"Last Name";
            playerTextField.keyboardType = UIKeyboardTypeDefault;
            playerTextField.returnKeyType = UIReturnKeyNext;
            if (lName.length) {
                playerTextField.text = lName;
            }
        }
        else if ([indexPath row] == 2) {
            playerTextField.tag = 10003;
            playerTextField.text = kGetUserDefault(@"UserEmail");
        }
        else if ([indexPath row] == 3) {
            playerTextField.tag = 10004;
            playerTextField.placeholder = @"05/06/1990";
            if (dob.length) {
                playerTextField.text = dob;
            }
        }
        else if ([indexPath row] == 4) {
            playerTextField.tag = 10005;
            playerTextField.placeholder = @"+91-9900990055";
            playerTextField.keyboardType = UIKeyboardTypePhonePad;
            playerTextField.returnKeyType = UIReturnKeyDone;
            if (phone.length) {
                playerTextField.text = phone;
            }
        }
        playerTextField.backgroundColor = [UIColor whiteColor];
        playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
        playerTextField.textAlignment = NSTextAlignmentLeft;
        playerTextField.delegate = self;
        
        playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
        [playerTextField setEnabled: YES];
        
        [cell.contentView addSubview:playerTextField];
    }
    
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            cell.textLabel.text = @"First Name";
        }
        else if ([indexPath row] == 1) {
            cell.textLabel.text = @"Last Name";
        }
        else if ([indexPath row] == 2) {
            cell.textLabel.text = @"Email";
        }
        else if ([indexPath row] == 3) {
            cell.textLabel.text = @"DOB";
        }
        else if ([indexPath row] == 4) {
            cell.textLabel.text = @"Phone";
        }
    }
    else { // Login button section
        cell.textLabel.text = @"Log in";
    }
    cell.textLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

#pragma mark - UITextField Delegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    currentTxtField = textField;
    if (textField.tag == 10003) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 10001) {
        fName = textField.text;
    } else if (textField.tag == 10002) {
        lName = textField.text;
    } else if (textField.tag == 10004) {
        dob = textField.text;
    } else if (textField.tag == 10005) {
        phone = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
