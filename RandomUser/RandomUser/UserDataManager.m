//
//  UserDataManager.m
//  RandomUser
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "UserDataManager.h"
#import <CoreData/CoreData.h>
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "RandomUserErroMessages.h"

#define kHexKey @"00831B24385C44BB04F474BDB8BB3E2C"

#define kBaseUrl  @"https://randomuser.me/api/?"
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
        NSLog(@"Current user’s home directory is %@", NSHomeDirectory());
    });
    return sharedInstance;
}

#pragma mark - Public API
-(void)getUserListWithSeed:(NSString * _Nullable)seed
                    gender:(NSString* _Nullable)gender
               resultCount:(NSUInteger)resultCount
       withCompletionBlock:(void(^)(NSArray <UserData * > * _Nullable users , RandomUserError * _Nullable error ))completionBlock {

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *path = @"";
    if (seed && seed.length) {
       path =  [NSString stringWithFormat:@"%@seed=%@&",path,seed];
    }
    if (gender && gender.length) {
        path =  [NSString stringWithFormat:@"%@gender=%@&",path,gender];
    }
    if (resultCount) {
        path =  [NSString stringWithFormat:@"%@results=%lu",path,(unsigned long)resultCount];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,path]];
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
                    UserData *details = [[UserData alloc]init];
                    details.seed  = [info objectForKey:kSeedKey];

                    if ( [userDict objectForKey:kNameKey]) {
                        details.name = [self getName:[userDict objectForKey:kNameKey]];
                    }

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
            
            RandomUserError *rmError = [[RandomUserError alloc] init];
            if (error.code == NSURLErrorTimedOut || error.code ==  NSURLErrorNetworkConnectionLost) {
                rmError.errorCode = CONNECTION_TIMEOUT;
                rmError.errorMessage = CONNECTION_TIMEOUT_MESSAGE;
            }
            else if (error.code == NSURLErrorNotConnectedToInternet) {
                rmError.errorCode = NO_INTERNET;
                rmError.errorMessage = NO_INTERNET_AVAILABLE_MESSAGE;
            }
            else{
                rmError.errorCode = INTERNAL_SERVER_ERROR;
                rmError.errorMessage = [error localizedDescription];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,rmError);
            });
        }
    } ];
    
    [dataTask resume];

}

- (void)getUserListFromCacheWithPageNo:(NSUInteger)pageNo pageSize:(NSUInteger)pageSize  withCompletionBlock:(void(^)(NSArray<UserData*> * _Nullable list, RandomUserError * _Nullable error))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            NSArray *users = [self getUsersFromCacheForPage:pageNo forPageSize:pageSize];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (users.count ==0) {
                    RandomUserError *rmError = [[RandomUserError alloc] init];
                    rmError.errorCode = NO_USER_DATA;
                    rmError.errorMessage = NO_USER_DATA_MESSAGE;
                    completionBlock(nil,rmError);
                }
                else {
                    completionBlock(users,nil);
                }
                
            });
        } @catch (NSException *exception) {
            
            NSLog(@"getUserListFromCacheWithCompletionBlock: Found Expeption: %@ ",exception.description);
            
            RandomUserError *rmError = [[RandomUserError alloc] init];
            rmError.errorCode = NO_USER_DATA;
            rmError.errorMessage = exception.description;
            completionBlock(nil,rmError);
        }
        
        
    });
}

- (void)cacheUser:(UserData * _Nonnull)userData
withCompletionBlock:(void(^)(BOOL isSuccess, RandomUserError * _Nullable error ))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            BOOL result = [self saveUserData:userData];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!result) {
                    RandomUserError *rmError = [[RandomUserError alloc] init];
                    rmError.errorCode = STORE_OPERATION_FAILED;
                    rmError.errorMessage = STORE_OPERATION_FAILED_MESSAGE;
                    completionBlock(nil,rmError);
                }
                else{
                    completionBlock(result,nil);
                }
                
            });
        } @catch (NSException *exception) {
            NSLog(@"cacheUser: Found Expeption: %@ ",exception.description);
            RandomUserError *rmError = [[RandomUserError alloc] init];
            rmError.errorCode = STORE_OPERATION_FAILED;
            rmError.errorMessage = exception.description;
            completionBlock(nil,rmError);
        }
        
    });
}


- (void)cacheUserList:(NSArray<UserData *> *_Nonnull)userDataList
  withCompletionBlock:(void(^)(BOOL isSuccess, RandomUserError * _Nullable error ))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            BOOL result = [self saveUserDataList:userDataList];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!result) {
                    RandomUserError *rmError = [[RandomUserError alloc] init];
                    rmError.errorCode = STORE_OPERATION_FAILED;
                    rmError.errorMessage = STORE_OPERATION_FAILED_MESSAGE;
                    completionBlock(nil,rmError);
                }
                else{
                    completionBlock(result,nil);
                }
                
            });
        } @catch (NSException *exception) {
            NSLog(@"cacheUserList: Found Expeption: %@ ",exception.description);
                RandomUserError *rmError = [[RandomUserError alloc] init];
                rmError.errorCode = STORE_OPERATION_FAILED;
                rmError.errorMessage = exception.description;
                completionBlock(nil,rmError);
        }
        
    });
}


- (void)deleteUser:(UserData * _Nonnull)userData
withCompletionBlock:(void(^)(BOOL isSuccess, RandomUserError * _Nullable error))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            BOOL result = [self deleteUserData:userData];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!result) {
                    RandomUserError *rmError = [[RandomUserError alloc] init];
                    rmError.errorCode = DELETE_OPERATION_FAILED;
                    rmError.errorMessage = DELETE_OPERATION_FAILED_MESSAGE;
                    completionBlock(nil,rmError);
                }
                else{
                    completionBlock(result,nil);
                }
            });
        } @catch (NSException *exception) {
            NSLog(@"deleteUser: Found Expeption: %@ ",exception.description);
            RandomUserError *rmError = [[RandomUserError alloc] init];
            rmError.errorCode = DELETE_OPERATION_FAILED;
            rmError.errorMessage = exception.description;
            completionBlock(nil,rmError);
        }
        
    });
}

- (void)deleteUserList:(NSArray<UserData *> *_Nonnull)userDataList
   withCompletionBlock:(void(^)(BOOL isSuccess, RandomUserError * _Nullable error ))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            BOOL result = [self deleteUserDataList:userDataList];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!result) {
                    RandomUserError *rmError = [[RandomUserError alloc] init];
                    rmError.errorCode = DELETE_OPERATION_FAILED;
                    rmError.errorMessage = DELETE_OPERATION_FAILED_MESSAGE;
                    completionBlock(nil,rmError);
                }
                else{
                    completionBlock(result,nil);
                }
            });
        } @catch (NSException *exception) {
            NSLog(@"deleteUserList: Found Expeption: %@ ",exception.description);
            RandomUserError *rmError = [[RandomUserError alloc] init];
            rmError.errorCode = DELETE_OPERATION_FAILED;
            rmError.errorMessage = exception.description;
            completionBlock(nil,rmError);
        }
        
    });
}



#pragma mark -Helper methods

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

-(NSArray<UserData*>*)getUsersFromCacheForPage:(NSUInteger)pageNo forPageSize:(NSUInteger)pageSize {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    request.fetchLimit = pageSize;
    request.fetchOffset = pageSize * (pageNo - 1 );
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    NSMutableArray *userListArray = [[NSMutableArray alloc]init];
    for (NSManagedObject *obj in results) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dict = [obj dictionaryWithValuesForKeys:keys];
        
        UserData *detail = [[UserData alloc]init];
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
            NSString *email = [dict objectForKey:kEmailKey];
            detail.email = [self decryptDataFromText:email];
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


-(BOOL)saveUserData:(UserData*)userData {
    if (![self isUserCached:userData]) {
        NSManagedObjectContext *context = self.persistentContainer.viewContext;
        NSManagedObject*userTable = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        [userTable setValue:userData.name forKey:@"name"];
        [userTable setValue:userData.gender forKey:@"gender"];
        NSString *encryptedMail = [self getEncryptedText:userData.email];
        [userTable setValue:encryptedMail forKey:@"email"];
        [userTable setValue:[NSNumber numberWithUnsignedInteger:userData.age] forKey:@"age"];
        [userTable setValue:userData.dob forKey:@"dob"];
        [userTable setValue:userData.seed forKey:@"seed"];
        NSLog(@"saveUserData");
        return [self saveContext];
    }
    else{
        
        NSLog(@"user exits %@",userData.name);
        return true;
    }
    
}


-(BOOL)saveUserDataList:(NSArray<UserData*>*)userDataList {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    for (UserData *userData in userDataList) {
        if (![self isUserCached:userData]) {
            NSManagedObject*userTable = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
            [userTable setValue:userData.name forKey:@"name"];
            [userTable setValue:userData.gender forKey:@"gender"];
            NSString *encryptedMail = [self getEncryptedText:userData.email];
            [userTable setValue:encryptedMail forKey:@"email"];
            [userTable setValue:[NSNumber numberWithUnsignedInteger:userData.age] forKey:@"age"];
            [userTable setValue:userData.dob forKey:@"dob"];
            [userTable setValue:userData.seed forKey:@"seed"];
            
            [self saveContext];
        }
        else{
            NSLog(@"user exits %@",userData.name);
        }
    }

    NSLog(@"saveUserData");
    return [self saveContext];
}

-(BOOL)isUserCached:(UserData *)userData {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",userData.name];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    return items.count > 0 ? true:false;
}

-(BOOL)deleteUserData:(UserData *)userData {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",userData.name];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items)
    {
        [context deleteObject:managedObject];
    }
    
    return [self saveContext];
}

-(BOOL)deleteUserDataList:(NSArray<UserData *> *)userDataList {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    for (UserData *userData in userDataList) {
        @try {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",userData.name];
            [fetchRequest setEntity:entity];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
            
            for (NSManagedObject *managedObject in items)
            {
                [context deleteObject:managedObject];
            }
            
            [self saveContext];
            
        } @catch (NSException *exception) {
            NSLog(@"deleteUserList: Found Expeption: %@ ",exception.description);
        }
    }
    NSLog(@"Delete UserData");
    return [self saveContext];
}

- (NSString *)getEncryptedText:(NSString *)clearText {
    NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:kHexKey
                                               error:&error];
    
    NSString *encryptedString = [self hexadecimalStringFromData:encryptedData];
    return encryptedString;
    
}


-(NSString *)decryptDataFromText:(NSString *)hex {
    NSData *encryptedData = [self dataFromHexString:hex];
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                        withPassword:kHexKey
                                               error:&error];
    NSString *email = [[NSString alloc]initWithData:decryptedData encoding:NSUTF8StringEncoding];
    return email;
}

- (NSString *)hexadecimalStringFromData:(NSData *)data {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

- (NSData *)dataFromHexString:(NSString *)string
{
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
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
    NSLog(@"CONTEXT %@",context);
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        return false;
    }
    return true;
}

@end
