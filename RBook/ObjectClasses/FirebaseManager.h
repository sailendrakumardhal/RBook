//
//  FirebaseManager.h
//  RBook
//
//  Created by Andola on 08/09/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseStorage/FirebaseStorage.h>

typedef void (^FirebaseManagerCompleteBlockWithObject) (id object, NSError *error);

@interface FirebaseManager : NSObject

@property (nonatomic, strong) FIRDatabaseReference *dbRef;
@property (nonatomic, strong) FIRAuth *authRef;
@property (nonatomic, strong) FIRStorage *storage;

+ (FirebaseManager*) sharedInstance;
- (void)dbReferenceWithChild:(NSString *)child andSuperChild:(NSString *)superChild;
- (void)retrieveDatawithCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete;
- (void)saveDataWithValue:(id)value withCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete;
- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password withCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete;
- (void)createUserWithEmail:(NSString *)email andPassword:(NSString *)password withCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete;
- (void)resetPasswordWithEmail:(NSString *)email withCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete;
- (void)signOutAccountWithCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete;
- (void)fetchConfigWithCompleteBlock:(FirebaseManagerCompleteBlockWithObject)complete;
- (void)uploadImageWithImageData: (NSData *)imgData withCompleteBlock: (FirebaseManagerCompleteBlockWithObject)complete;
- (void)downloadImageWithCompleteBlock: (FirebaseManagerCompleteBlockWithObject)complete;

@end
