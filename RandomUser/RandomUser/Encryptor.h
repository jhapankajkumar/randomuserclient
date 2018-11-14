//
//  Encryptor.h
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encryptor : NSObject
+(NSData *)encrypt:(NSData *)digestData;
+(NSData *)decrypt:(NSData *)digestData;
@end
