//
//  UserDataManager.h
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDetail.h"


@interface UserDataManager : NSObject

+(instancetype)sharedInstance;

-(void)getUserListWithSeed:(NSString * _Nullable)seed
                    gender:(NSString* _Nullable)gender
               resultCount:(NSUInteger)resultCount
       withCompletionBlock:(void(^)(NSArray <UserDetail *>*users, NSError *error))completionBlock;

- (void)saveUser:(NSDictionary *)userData
withCompletionBlock:(void(^)(BOOL isSuccess))completionBlock;


- (void)getStoredUserFromCacheWithCompletionBlock:(void(^)(NSArray<UserDetail*>* list))completionBlock;

@end
