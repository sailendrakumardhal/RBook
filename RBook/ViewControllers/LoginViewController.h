//
//  LoginViewController.h
//  RBook
//
//  Created by Andola on 13/09/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tblCred;
- (IBAction)btnForgotPwdOnClicked:(id)sender;

@end
