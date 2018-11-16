//
//  User+CoreDataProperties.h
//  
//
//  Created by Gyan on 16/11/18.
//
//  This file was automatically generated and should not be edited.
//

#import "User+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest;

@property (nonatomic) int16_t age;
@property (nullable, nonatomic, copy) NSString *dob;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *gender;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *seed;

@end

NS_ASSUME_NONNULL_END
