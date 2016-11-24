//
//  CreateUserViewController.m
//  RBook
//
//  Created by Andola on 14/09/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import "CreateUserViewController.h"
#import "FirebaseManager.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import "Constant.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface CreateUserViewController () <UITextFieldDelegate>
{
    UITextField *currentTxtField;
    NSString *userEmail, *userPassword;
    int direction;
    int shakes;
}

@end

@implementation CreateUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationItem.title = @"Create Account";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(btnCreateClicked:)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.tblCreateUser.layer.cornerRadius = 5.0f;
    self.tblCreateUser.layer.masksToBounds = YES;
    self.tblCreateUser.tableHeaderView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Action

-(void)btnCreateClicked:(UIButton *)sender {
    [currentTxtField resignFirstResponder];
    if (userEmail.length == 0 || userPassword.length == 0 || [userPassword isEqualToString:@""] || [userEmail isEqualToString:@""]) {
        [APP_DELEGATE displayMessageWithTitle:@"RBook" withMessage:@"Please enter valid data !" andAlertType:ISAlertTypeError];
//        [self shake:(UIView *)currentTxtField];
        return;
    }
    self.navigationItem.rightBarButtonItem = nil;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] init];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicator.alpha = 1.0;
    activityIndicator.hidesWhenStopped = YES;
    
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
    
    [[FirebaseManager sharedInstance] createUserWithEmail:userEmail andPassword:userPassword withCompleteBlock:^(id object, NSError *error) {
        
        FIRUser *userRef = (FIRUser *)object;
        if (userRef) {
            [activityIndicator stopAnimating];
            kUpdateUserDefault(@"UserAuth", userRef.uid);
            kUpdateUserDefault(@"UserEmail", userEmail);
            
            ViewController *rcpDtlVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeVC"];
            rcpDtlVC.isFromCreateAccount = YES;
            [self.navigationController pushViewController:rcpDtlVC animated:YES];
        } else {
            [activityIndicator stopAnimating];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(btnCreateClicked:)];
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            
            [APP_DELEGATE displayMessageWithTitle:@"RBook" withMessage:error.localizedDescription andAlertType:ISAlertTypeError];
        }
    }];
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([indexPath section] == 0) {
            UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
            playerTextField.adjustsFontSizeToFitWidth = YES;
            playerTextField.textColor = [UIColor blackColor];
            
            if ([indexPath row] == 0) {
                playerTextField.tag = 10001;
                playerTextField.placeholder = @"example@gmail.com";
                playerTextField.keyboardType = UIKeyboardTypeEmailAddress;
                playerTextField.returnKeyType = UIReturnKeyNext;
                [playerTextField becomeFirstResponder];
            }
            else {
                playerTextField.tag = 10002;
                playerTextField.placeholder = @"Required";
                playerTextField.keyboardType = UIKeyboardTypeDefault;
                playerTextField.returnKeyType = UIReturnKeyDone;
                playerTextField.secureTextEntry = YES;
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
    }
    if ([indexPath section] == 0) { // Email & Password Section
        if ([indexPath row] == 0) { // Email
            cell.textLabel.text = @"Email";
        }
        else {
            cell.textLabel.text = @"Password";
        }
    }
    else { // Login button section
        cell.textLabel.text = @"Log in";
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

#pragma mark - UITextField

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    currentTxtField = textField;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 10001) {
        userEmail = textField.text;
    } else if (textField.tag == 10002) {
        userPassword = textField.text;
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

#pragma mark - Other

//-(void)shake:(UIView *)theOneYouWannaShake
//{
//    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
//    [shake setDuration:0.1];
//    [shake setRepeatCount:2];
//    [shake setAutoreverses:YES];
//    [shake setFromValue:[NSValue valueWithCGPoint:
//                         CGPointMake(theOneYouWannaShake.center.x - 5,theOneYouWannaShake.center.y)]];
//    [shake setToValue:[NSValue valueWithCGPoint:
//                       CGPointMake(theOneYouWannaShake.center.x + 5, theOneYouWannaShake.center.y)]];
//    [theOneYouWannaShake.layer addAnimation:shake forKey:@"position"];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
