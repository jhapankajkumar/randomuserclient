//
//  UserStoreManager.h
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UserDetails.h"

@interface UserStoreManager : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+(instancetype)sharedInstance;

//method to save the context
- (void)saveContext;
-(void)saveUserDataFromResponse:(NSArray <UserDetails *> *)userList;
@end
