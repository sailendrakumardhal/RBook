//
//  URLRequest.h
//  RBook
//
//  Created by Andola on 24/08/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ConnectionCompleteBlockWithObject) (id object, NSError *error);

@interface URLRequest : NSObject

+ (URLRequest *) sharedInstance;

-(void)APIPostReauestWithService:(NSString *)strServiceName withParameter:(NSString *)strParameters andHTTPMethod:(NSString *)httpMehod withCompleteBlock:(ConnectionCompleteBlockWithObject)completeBlock;

@end
