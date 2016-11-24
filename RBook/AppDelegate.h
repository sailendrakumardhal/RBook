//
//  AppDelegate.h
//  RBook
//
//  Created by Andola on 24/08/16.
//  Copyright © 2016 Andola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Firebase/Firebase.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseRemoteConfig/FirebaseRemoteConfig.h>
#import <ISMessages/ISMessages.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) FIRDatabaseReference *dbRef;
@property (nonatomic, strong) FIRRemoteConfig *configRef;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)displayMessageWithTitle: (NSString *)title withMessage: (NSString *)msg andAlertType: (ISAlertType)alertType;

@end

