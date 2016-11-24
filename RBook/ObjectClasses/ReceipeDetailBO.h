//
//  ReceipeDetailBO.h
//  RBook
//
//  Created by Andolasoft on 8/26/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>

@interface ReceipeDetailBO : JSONModel

@property (nonatomic, strong) NSString *f2f_url;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *publisher;
@property (nonatomic, strong) NSString *publisher_url;
@property (nonatomic, strong) NSString *recipe_id;
@property (nonatomic, strong) NSString *social_rank;
@property (nonatomic, strong) NSString *source_url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray  *ingredients;

@end
