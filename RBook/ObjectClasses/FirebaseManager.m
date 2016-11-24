//
//  FirebaseManager.m
//  RBook
//
//  Created by Andola on 08/09/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import "FirebaseManager.h"
#import "Constant.h"
#import "AppDelegate.h"

@implementation FirebaseManager

#pragma mark - Other Operational methods

- (void)dbReferenceWithChild:(NSString *)child andSuperChild:(NSString *)superChild
{
    self.dbRef = APP_DELEGATE.dbRef;
    self.dbRef = [self.dbRef child:child];
    if (superChild.length) {
        self.dbRef = [self.dbRef child:superChild];
    }
}

- (void)fetchConfigWithCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete {
    long expirationDuration = 3600;
    // If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from
    // the server.
    if (APP_DELEGATE.configRef.configSettings.isDeveloperModeEnabled) {
        expirationDuration = 0;
    }
    
    // [START fetch_config_with_callback]
    // cacheExpirationSeconds is set to cacheExpiration here, indicating that any previously
    // fetched and cached config would be considered expired because it would have been fetched
    // more than cacheExpiration seconds ago. Thus the next fetch would go to the server unless
    // throttling is in progress. The default expiration duration is 43200 (12 hours).
    [APP_DELEGATE.configRef fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            NSLog(@"Config fetched!");
            [APP_DELEGATE.configRef activateFetched];
            complete (@"true", nil);
        } else {
            NSLog(@"Config not fetched");
            NSLog(@"Error %@", error.localizedDescription);
            complete (nil, error);
        }
    }];
    // [END fetch_config_with_callback]
}

- (void)retrieveDatawithCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete
{
    [self.dbRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        id response;
        if (![snapshot.value isKindOfClass:[NSNull class]]) {
            response = snapshot.value;
        }
        
        if (complete) {
            complete(response, nil);
        }
    }];
    [self.dbRef removeObserverWithHandle:FIRDataEventTypeValue];
}

- (void)saveDataWithValue:(id)value withCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete
{
    [self.dbRef setValue:value withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (error) {
            complete(nil, error);
        } else {
            complete(ref, nil);
        }
    }];
    [self.dbRef removeObserverWithHandle:FIRDataEventTypeValue];
}

- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password withCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete
{
    self.authRef = [FIRAuth auth];
    [self.authRef signInWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        if (user) {
            complete (user, nil);
        } else {
            complete (nil, error);
        }
    }];
}

- (void)createUserWithEmail:(NSString *)email andPassword:(NSString *)password withCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete
{
    self.authRef = [FIRAuth auth];
    [self.authRef createUserWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        if (user) {
            complete (user, nil);
        } else {
            complete (nil, error);
        }
    }];
}

- (void)resetPasswordWithEmail:(NSString *)email withCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete
{
    self.authRef = [FIRAuth auth];
    [self.authRef sendPasswordResetWithEmail:email completion:^(NSError * _Nullable error) {
        if (!error) {
            complete (@"sent", nil);
        } else {
            complete (nil, error);
        }
    }];
}

- (void)signOutAccountWithCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete
{
    self.authRef = [FIRAuth auth];
    NSError *error;
    [self.authRef signOut:&error];
    if (!error) {
        complete (@"success", nil);
    } else {
        complete (nil, error);
    }
}

- (void)uploadImageWithImageData: (NSData *)imgData withCompleteBlock: (FirebaseManagerCompleteBlockWithObject)complete
{
    if (imgData.length) {
        self.storage = [FIRStorage storage];
        FIRStorageReference *storageRef = [self.storage reference];
        
        // Create a child reference
        // imagesRef now points to "images"
        storageRef = [storageRef child:@"profileimage"];
        
        // Child references can also take paths delimited by '/'
        // spaceRef now points to "images/space.jpg"
        // imagesRef still points to "images"
        storageRef = [storageRef child:[NSString stringWithFormat:@"/%@.jpg", kGetUserDefault(@"UserAuth")]];
        
        // Create file metadata including the content type
        FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
        metadata.contentType = @"image/jpeg";
        
        // Upload data and metadata
        [storageRef putData:imgData metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if (!error) {
                complete (@"", nil);
            } else {
                complete (nil, error);
            }
        }];
    } else {
        
    }
}

- (void)downloadImageWithCompleteBlock: (FirebaseManagerCompleteBlockWithObject)complete
{
    self.storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [self.storage reference];
    
    // Create a child reference
    // imagesRef now points to "images"
    storageRef = [storageRef child:@"profileimage"];
    
    // Child references can also take paths delimited by '/'
    // spaceRef now points to "images/space.jpg"
    // imagesRef still points to "images"
    storageRef = [storageRef child:[NSString stringWithFormat:@"/%@.jpg", kGetUserDefault(@"UserAuth")]];
    
    [storageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        if (!error) {
            complete (URL, nil);
        } else {
            complete (nil, error);
        }
    }];
}

#pragma mark - Singleton
static FirebaseManager* _singletonInstance = nil;

+ (FirebaseManager*) sharedInstance {
    if (_singletonInstance == nil) {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            _singletonInstance = [[FirebaseManager alloc] init];
        });
    }
    
    return _singletonInstance;
}

@end
