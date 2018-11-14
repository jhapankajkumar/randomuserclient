//
//  UserDataManager.m
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "UserDataManager.h"
#import "UserStoreManager.h"

#define BaseUrl  @"https://randomuser.me/api/?"

#define kNameKey @"name"
#define kAgeKey @"age"
#define kGenderKey @"gender"
#define kEmailKey @"email"
#define kDOBKey @"dob"
#define kSeedKey @"seed"


@implementation UserDataManager
-(void)getUserListWithSeed:(NSString * _Nullable)seed gender:(NSString* _Nullable)gender resultCount:(NSUInteger)resultCount withCompletionBlock:(void(^)(NSArray <UserDetails *>*users, NSError *error))completionBlock {

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = @"https://randomuser.me/api/?";
    if (seed && seed.length) {
       urlString =  [NSString stringWithFormat:@"%@seed=%@",urlString,seed];
    }
    if (gender && gender.length) {
        urlString =  [NSString stringWithFormat:@"%@gender=%@",urlString,gender];
    }
    if (resultCount) {
        urlString =  [NSString stringWithFormat:@"%@results=%lu",urlString,(unsigned long)resultCount];
    }
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error==nil) {
            
            NSMutableArray *userList = [[NSMutableArray alloc]init];
            NSDictionary *apiResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *info = [apiResult objectForKey:@"info"];
            NSArray *list = [apiResult objectForKey:@"results"];
            if (list.count >0) {
                for (NSDictionary *userDict in list) {
                    UserDetails *details = [[UserDetails alloc]init];
                    
                    details.seed  = [info objectForKey:kSeedKey];
                    
                    //if Name is present
                    if ( [userDict objectForKey:kNameKey]) {
                        details.name = [self getName:[userDict objectForKey:kNameKey]];
                    }
                    //if gender is present
                    if ( [userDict objectForKey:kGenderKey]) {
                        details.gender = [userDict objectForKey:kGenderKey];
                    }
                    
                    if ( [userDict objectForKey:kDOBKey]) {
                        details.dob = [[userDict objectForKey:kDOBKey] objectForKey:@"date"];
                        details.age = [[[userDict objectForKey:kDOBKey] objectForKey:@"age"] integerValue];
                    }
                    
                    if ( [userDict objectForKey:kEmailKey]) {
                        details.email = [userDict objectForKey:kEmailKey];
                    }
                    
                    [userList  addObject:details];
                }
                
                //Call method to store the data
                [self saveUsersData:userList];
                
                completionBlock(userList,nil);
                
            }
        }
        
    } ];
    
    [dataTask resume];

}

-(NSString *)getName:(NSDictionary *)nameDict {
    NSString *fullName = @"";
    if ([nameDict objectForKey:@"first"]){
        fullName = [nameDict objectForKey:@"first"];
    }
    
    if ([nameDict objectForKey:@"last"]){
        fullName = [NSString stringWithFormat:@"%@ %@",fullName,[nameDict objectForKey:@"last"]];
    }
    return fullName;
}

-(void)saveUsersData:(NSArray<UserDetails *> *)apiResponse {
    [[UserStoreManager sharedInstance] saveUserDataFromResponse:apiResponse];
}
@end
