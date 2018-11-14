//
//  UserDetails.h
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDetails : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *seed;
@property (nonatomic, strong) NSString *dob;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic) NSUInteger age;
@end
