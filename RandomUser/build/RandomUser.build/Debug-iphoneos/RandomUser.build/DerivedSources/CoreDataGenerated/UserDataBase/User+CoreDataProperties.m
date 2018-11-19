//
//  User+CoreDataProperties.m
//  
//
//  Created by Gyan on 19/11/18.
//
//  This file was automatically generated and should not be edited.
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"User"];
}

@dynamic age;
@dynamic dob;
@dynamic email;
@dynamic gender;
@dynamic name;
@dynamic seed;

@end
