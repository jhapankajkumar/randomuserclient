//
//  UserDataManager.h
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDetails.h"


@interface UserDataManager : NSObject

-(void)getUserListWithSeed:(NSString * _Nullable)seed gender:(NSString* _Nullable)gender resultCount:(NSUInteger)resultCount withCompletionBlock:(void(^)(NSArray <UserDetails *>*users, NSError *error))completionBlock;
@end
