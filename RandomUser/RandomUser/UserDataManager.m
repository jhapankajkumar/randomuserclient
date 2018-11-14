//
//  UserDataManager.m
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "UserDataManager.h"
#import "UserStoreManager.h"

#define BaseUrl  "https://randomuser.me/api/?"

@implementation UserDataManager
-(void)getUserListWithSeed:(NSString * _Nullable)seed gender:(NSString* _Nullable)gender resultCount:(NSUInteger)resultCount withCompletionBlock:(void(^)(NSArray *users, NSError *error))completionBlock {

    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableString *urlString = BaseUrl;
    if (seed && seed.length) {
        [urlString appendString:"seed=%@",seed];
    }
    if (gender && gender.length) {
        [urlString appendString:"gender=%@",gender];
    }
    if (resultCount) {
        [urlString appendString:"results=%@",resultCount];
    }
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error==nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:error];
            if (error== nil) {
                dict
            }
            
        }
        
    } ]

}

-(void)saveUsersData:(NSDictionary *)apiResponse {
    N
}
@end
