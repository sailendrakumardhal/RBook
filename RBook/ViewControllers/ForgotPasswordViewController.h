//
//  ForgotPasswordViewController.h
//  RBook
//
//  Created by Andola on 15/09/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController

- (IBAction)btnSendOnCLick:(id)sender;
- (IBAction)btnCloseView:(id)sender;

@property (nonatomic, strong) IBOutlet UIButton *btnSend;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;

@end
