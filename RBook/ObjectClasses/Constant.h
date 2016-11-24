//
//  Constant.h
//  RBook
//
//  Created by Andola on 24/08/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define SCREEN_SIZE ([[UIScreen mainScreen] bounds].size)

#define BASE_URL        @"http://food2fork.com/api/" // use any api end point

#define FIREBASE_ROOT_URL        @"https://rbook-c4027.firebaseio.com/" // Replace with your Firebase url

#define API_KEY         @"your api key" //If not then register or can use any api

#define POST            @"POST"
#define GET             @"GET"

#define SORTINGBYRATING             @"r"
#define SORTINGBYTRAINDING             @"t"

//Service names

#define GET_RECIPES                 @"get"
#define SEARCH_RECIPES              @"search"

#define APP_DELEGATE    ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define kUpdateUserDefault(key,value){\
[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];\
}
#define kGetUserDefault(key)[[NSUserDefaults standardUserDefaults] objectForKey:key]

#define kRemoveUserDefault(key)[[NSUserDefaults standardUserDefaults] removeObjectForKey:key]

#endif /* Constant_h */
