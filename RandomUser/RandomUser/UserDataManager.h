//
//  UserDataManager.h
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"
#import "RandomUserError.h"



@interface UserDataManager : NSObject

/**
 * Get the single instance of the class
 * @return Singleton instance of the class
 */
+(instancetype)sharedInstance;

/**
 * Get the user list from the server.
 *
 * @param seed a User id for the group of user.
 * @param gender Gender of the user
 * @param resultCount total count of desired result
 * @param completionBlock call back for the api response with user list or error.
 */
-(void)getUserListWithSeed:(NSString * _Nullable)seed
                    gender:(NSString* _Nullable)gender
               resultCount:(NSUInteger)resultCount
       withCompletionBlock:(void(^)(NSArray <UserData * > * _Nullable users , RandomUserError * _Nullable error ))completionBlock;


/**
 * Store the user to cache
 * @param userData User data to be store in cache
 * @param completionBlock call back  with success/failure or error.
 */
- (void)cacheUser:(UserData * _Nonnull)userData
withCompletionBlock:(void(^)(BOOL isSuccess, RandomUserError * _Nullable error ))completionBlock;


/**
 * Store the multiple user to cache
 * @param userData User data to be store in cache
 * @param completionBlock call back  with success/failure or error.
 */
- (void)cacheUserList:(NSArray<UserData *> *_Nonnull)userData
withCompletionBlock:(void(^)(BOOL isSuccess, RandomUserError * _Nullable error ))completionBlock;


/**
 * Delete the user from cache
 * @param userData User data to be deleted from cache
 * @param completionBlock call back  with success/failure or error.
 */
- (void)deleteUser:(UserData * _Nonnull)userData
withCompletionBlock:(void(^)(BOOL isSuccess, RandomUserError * _Nullable error))completionBlock;


/**
 * Delete the multiple user to cache
 * @param userDataList  list of User data to be deleted from cache
 * @param completionBlock call back  with success/failure or error.
 */
- (void)deleteUserList:(NSArray<UserData *> *_Nonnull)userDataList
  withCompletionBlock:(void(^)(BOOL isSuccess, RandomUserError * _Nullable error ))completionBlock;

/**
 * Retrieve the user to cache
 * @param completionBlock call back user list.
 */
- (void)getUserListFromCacheWithCompletionBlock:(void(^)(NSArray<UserData*> * _Nullable list, RandomUserError * _Nullable error))completionBlock;

@end
