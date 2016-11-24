//
//  ProfileViewController.h
//  RBook
//
//  Created by Andola on 16/09/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"UIImageView+WebCache.h"

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)btnCloseOnClicked:(id)sender;
- (IBAction)btnProfileOnClicked:(id)sender;
- (IBAction)btnDoneOnclicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *BtnDone;
@property (strong, nonatomic) IBOutlet UIButton *btnProfile;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewBG;
@property (strong, nonatomic) IBOutlet UITableView *tblProfileData;

@property (strong, nonatomic) UIImage *profileImage;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic) BOOL isViewProfile;

@end
