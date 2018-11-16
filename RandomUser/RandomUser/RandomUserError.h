//
//  RandomUserError.h
//  RandomUser
//
//  Created by Gyan on 16/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RandomUserErrorCodes.h"

@interface RandomUserError : NSObject
/**
 * Provides the SDK Error code occurred.
 *
 */
@property (nonatomic) RUErrorCode errorCode;

/**
 * Provides the description of the error.
 *
 */
@property (nonatomic,strong) NSString * errorMessage;

@end
