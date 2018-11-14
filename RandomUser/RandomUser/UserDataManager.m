//
//  UserDataManager.m
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "UserDataManager.h"
#import <CoreData/CoreData.h>

#define BaseUrl  @"https://randomuser.me/api/?"
#define kNameKey @"name"
#define kAgeKey @"age"
#define kGenderKey @"gender"
#define kEmailKey @"email"
#define kDOBKey @"dob"
#define kSeedKey @"seed"


@interface UserDataManager ()
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (readonly, strong) NSManagedObjectModel *mom;
@end

@implementation UserDataManager
@synthesize persistentContainer = _persistentContainer;
@synthesize mom  = _mom;

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)getUserListWithSeed:(NSString * _Nullable)seed gender:(NSString* _Nullable)gender resultCount:(NSUInteger)resultCount withCompletionBlock:(void(^)(NSArray <UserDetail *>*users, NSError *error))completionBlock {

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = @"https://randomuser.me/api/?";
    if (seed && seed.length) {
       urlString =  [NSString stringWithFormat:@"%@seed=%@&",urlString,seed];
    }
    if (gender && gender.length) {
        urlString =  [NSString stringWithFormat:@"%@gender=%@&",urlString,gender];
    }
    if (resultCount) {
        urlString =  [NSString stringWithFormat:@"%@results=%lu",urlString,(unsigned long)resultCount];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"GetUserList: URL: %@",url.absoluteString);
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error==nil) {
            
            NSMutableArray *userList = [[NSMutableArray alloc]init];
            NSDictionary *apiResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *info = [apiResult objectForKey:@"info"];
            NSArray *list = [apiResult objectForKey:@"results"];
            NSLog(@"GetUserList: list count: %lu",(unsigned long)list.count);
            if (list.count >0) {
                for (NSDictionary *userDict in list) {
                    UserDetail *details = [[UserDetail alloc]init];
                    
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock(userList,nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,error);
            });
        }
    } ];
    
    [dataTask resume];

}

- (void)getStoredUserFromCacheWithCompletionBlock:(void(^)(NSArray<UserDetail*>* list))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *users = [self getUsersFromCache];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(users);
        });
    });
}

- (void)saveUser:(UserDetail *)userData withCompletionBlock:(void(^)(BOOL isSuccess))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self saveUserData:userData];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(result);
        });
    });
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

-(NSArray<UserDetail*>*)getUsersFromCache {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    NSMutableArray *userListArray = [[NSMutableArray alloc]init];
    for (NSManagedObject *obj in results) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dict = [obj dictionaryWithValuesForKeys:keys];
        
        UserDetail *detail = [[UserDetail alloc]init];
        if ([dict objectForKey:kNameKey]) {
            detail.name = [dict objectForKey:kNameKey];
        }
        
        if ([dict objectForKey:kGenderKey]) {
            detail.gender = [dict objectForKey:kGenderKey];
        }
        
        if ([dict objectForKey:kAgeKey]) {
            detail.age = [[dict objectForKey:kAgeKey] integerValue];
        }
        
        if ([dict objectForKey:kEmailKey]) {
            detail.email = [dict objectForKey:kEmailKey];
        }
        
        if ([dict objectForKey:kDOBKey]) {
            detail.dob = [dict objectForKey:kDOBKey];
        }
        
        if ([dict objectForKey:kNameKey]) {
            detail.seed = [dict objectForKey:kSeedKey];
        }
        
        [userListArray addObject:detail];
        
    }
    return userListArray;
}

-(BOOL)saveUserData:(UserDetail*)userDetail {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSManagedObject*userTable = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [userTable setValue:userDetail.name forKey:@"name"];
    [userTable setValue:userDetail.gender forKey:@"gender"];
    [userTable setValue:userDetail.email forKey:@"email"];
    [userTable setValue:[NSNumber numberWithUnsignedInteger:userDetail.age] forKey:@"age"];
    [userTable setValue:userDetail.dob forKey:@"dob"];
    [userTable setValue:userDetail.seed forKey:@"seed"];
    return [self saveContext];
}

#pragma mark - Core Data stack


- (NSManagedObjectModel*)mom {
    if (_mom == nil) {
        NSBundle *bundel = [NSBundle bundleWithIdentifier:@"com..RandomUser"];
        NSURL *modelUrl = [bundel URLForResource:@"UserDataBase" withExtension:@"momd"];
        _mom = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelUrl];
    }
    return _mom;
}

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"UserDataBase" managedObjectModel:self.mom];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

-(BOOL)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        return false;
    }
    return true;
}

@end
