//
//  ForgotPasswordViewController.m
//  RBook
//
//  Created by Andola on 15/09/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "FirebaseManager.h"
#import "AppDelegate.h"
#import "Constant.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnSend.layer.cornerRadius = 4.0f;
    self.btnSend.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSendOnCLick:(id)sender {
    if ([[self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        
        [APP_DELEGATE displayMessageWithTitle:@"RBook" withMessage:@"Please enter valid email id !" andAlertType:ISAlertTypeError];
        
        return;
    }
    [self.txtEmail resignFirstResponder];
    [[FirebaseManager sharedInstance] resetPasswordWithEmail:self.txtEmail.text withCompleteBlock:^(id object, NSError *error) {
        self.txtEmail.text = @"";
        if (!error) {
            [APP_DELEGATE displayMessageWithTitle:@"RBook" withMessage:@"Reset password link has been sent to your registered email id" andAlertType:ISAlertTypeSuccess];
        } else {
            [APP_DELEGATE displayMessageWithTitle:@"RBook" withMessage:error.localizedDescription andAlertType:ISAlertTypeError];
        }
    }];
}

- (IBAction)btnCloseView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
