//
//  RandomUserErrorCodes.h
//  RandomUser
//
//  Created by Gyan on 16/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#ifndef RandomUserErrorCodes_h
#define RandomUserErrorCodes_h

/*!
 RUErrorCode enum
 @abstract Describes error code of Random User
 */
typedef NS_ENUM(NSInteger,RUErrorCode) {
    /**
     * This is the error code of type no internet
     */
    NO_INTERNET,
    /**
     * This is the error code of type time out
     */
    CONNECTION_TIMEOUT,
    /**
     * This is the error code of type communication error
     */
    INTERNAL_SERVER_ERROR,
    /**
     * This is error code will be set if there is no stored user data
     */
    NO_USER_DATA,
    
    /**
     * This is error code will be set if store  user fail
     */
    STORE_OPERATION_FAILED,
    
    /**
     * This is error code will be set if delete user fail
     */
    DELETE_OPERATION_FAILED
    
};


#endif /* RandomUserErrorCodes_h */
