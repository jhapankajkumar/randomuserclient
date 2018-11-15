//
//  UserDataManager.h
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"


@interface UserDataManager : NSObject

/*!
 * Get the single instance of the class
 * @return Singleton instance of the class
 */
+(instancetype)sharedInstance;

/*!
 * Get the user list from the server.
 * @note: Payment with other than default card is not allowed. In case you want to make payment with different card, please make that card as default card and then make payment.
 *
 * @param seed a User id for the group of user.
 * @param gender Gender of the user
 * @param resultCount total count of desired result
 * @param completionBlock call back for the api response with user list or error.
 */
-(void)getUserListWithSeed:(NSString * _Nullable)seed
                    gender:(NSString* _Nullable)gender
               resultCount:(NSUInteger)resultCount
       withCompletionBlock:(void(^)(NSArray <UserData * > * _Nullable users , NSError * _Nullable error ))completionBlock;


/*!
 * Store the user to cache
 * @param userData User data to be store in cache
 * @param completionBlock call back  with user list or error.
 */
- (void)cacheUser:(UserData * _Nonnull)userData
withCompletionBlock:(void(^)(BOOL isSuccess))completionBlock;


/*!
 * Delete the user from cache
 * @param userData User data to be deleted from cache
 * @param completionBlock call back  with user list or error.
 */
- (void)deleteUser:(UserData * _Nonnull)userData
withCompletionBlock:(void(^)(BOOL isSuccess))completionBlock;

/*!
 * Retrieve the user to cache
 * @param completionBlock call back user list.
 */
- (void)getUserListFromCacheWithCompletionBlock:(void(^)(NSArray<UserData*> * _Nullable list))completionBlock;

@end
