//
//  CreateUserViewController.h
//  RBook
//
//  Created by Andola on 14/09/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tblCreateUser;

@end
