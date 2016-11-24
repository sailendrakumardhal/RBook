//
//  ReceipeCell.h
//  RBook
//
//  Created by Andolasoft on 8/26/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceipeCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgVwReceipe;
@property (weak, nonatomic) IBOutlet UILabel *lblTitlercp;
@property (weak, nonatomic) IBOutlet UILabel *lblSocialRating;

@end
