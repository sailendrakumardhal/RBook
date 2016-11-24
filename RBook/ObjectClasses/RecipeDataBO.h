//
//  RecipeDataBO.h
//  RBook
//
//  Created by Andola on 24/08/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface RecipeDataBO : JSONModel

@property(strong,nonatomic)NSString *publisher;
@property(strong,nonatomic)NSString *f2f_url;
@property(strong,nonatomic)NSString *title;
@property(strong,nonatomic)NSString *source_url;
@property(strong,nonatomic)NSString *recipe_id;
@property(strong,nonatomic)NSString *image_url;
@property(strong,nonatomic)NSString *social_rank;
@property(strong,nonatomic)NSString *publisher_url;

@end
