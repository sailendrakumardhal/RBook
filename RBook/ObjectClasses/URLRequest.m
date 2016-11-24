//
//  URLRequest.m
//  RBook
//
//  Created by Andola on 24/08/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import "URLRequest.h"
#import "Constant.h"

@implementation URLRequest

-(void)APIPostReauestWithService:(NSString *)strServiceName withParameter:(NSString *)strParameters andHTTPMethod:(NSString *)httpMehod withCompleteBlock:(ConnectionCompleteBlockWithObject)completeBlock
{
    NSData *postData = [strParameters dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", BASE_URL, strServiceName];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:httpMehod];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                  
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          // Handle error...
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                      }
                                      NSDictionary *dictBody =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                      
                                      if (dictBody.count) {
                                          if (completeBlock) {
                                              completeBlock(dictBody, nil);
                                          }
                                      }
                                  }];
    [task resume];
}

#pragma mark - Singleton
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Singleton ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
static URLRequest* _singletonInstance = nil;

+ (URLRequest *) sharedInstance {
    if (_singletonInstance == nil) {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            _singletonInstance = [[URLRequest alloc] init];
        });
    }
    
    return _singletonInstance;
}

@end
