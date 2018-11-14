//
//  UserStoreManager.m
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "UserStoreManager.h"
#import "User+CoreDataClass.h"
#import "User+CoreDataProperties.h"
#import <CommonCrypto/CommonDigest.h>

@implementation UserStoreManager
@synthesize persistentContainer = _persistentContainer;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


-(void)saveUserDataFromResponse:(NSArray <UserDetails *> *)userList; {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
   
    if (userList.count > 0) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
        for (UserDetails *details in userList) {
            [entityDescription setValue:details.name forKey:@"name"];
            [entityDescription setValue:details.gender forKey:@"gender"];
            [entityDescription setValue:details.email forKey:@"email"];
            [entityDescription setValue:[NSNumber numberWithUnsignedInteger:details.age] forKey:@"age"];
            [entityDescription setValue:details.dob forKey:@"dob"];
            [entityDescription setValue:details.seed forKey:@"seed"];
        }
        
        [self saveContext];
    }
}

#pragma mark - Core Data stack

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Users"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
