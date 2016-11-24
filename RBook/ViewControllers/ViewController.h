//
//  ViewController.h
//  RBook
//
//  Created by Andola on 24/08/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodCollectionViewCell.h"
#import"UIImageView+WebCache.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *foodCollection;

@property(strong,nonatomic)NSMutableArray *arrrecepiData;

@property (nonatomic) BOOL isFromCreateAccount;

@end

