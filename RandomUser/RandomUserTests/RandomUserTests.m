//
//  RandomUserTests.m
//  RandomUserTests
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RandomUser/UserDataManager.h>

@interface RandomUserTests : XCTestCase

@end

@implementation RandomUserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


-(void)test_001_getUserList {
    __block XCTestExpectation * onCompleteExpectation = [self expectationWithDescription:@"onComplete"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSLog(@"Current user’s home directory is %@", NSHomeDirectory());
        [[UserDataManager sharedInstance] getUserListWithSeed:@"002" gender:@"female" resultCount:10 withCompletionBlock:^(NSArray *users, NSError *error) {
            XCTAssertEqual(users.count,10);
            XCTAssertNil(error);
            [onCompleteExpectation fulfill];
        }];
    });
    
    [self waitForExpectations:[NSArray arrayWithObjects:onCompleteExpectation, nil] timeout:100];
}

-(void)test_002_storeUserToCache {
    __block XCTestExpectation * onCompleteExpectation = [self expectationWithDescription:@"onComplete"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        UserData *data = [[UserData alloc]init];
        data.seed = @"677745";
        data.email = @"random@gmail.com";
        data.gender = @"male";
        data.name = @"test user";
        data.age = 29;
        data.dob = @"Today";
        
        [[UserDataManager sharedInstance] cacheUser:data withCompletionBlock:^(BOOL isSuccess) {
            XCTAssertTrue(isSuccess);
            [onCompleteExpectation fulfill];
        }];
    });
    
    [self waitForExpectations:[NSArray arrayWithObjects:onCompleteExpectation, nil] timeout:100];
}


-(void)test_003_getUserFromCache {
    __block XCTestExpectation * onCompleteExpectation = [self expectationWithDescription:@"onComplete"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        UserData *data = [[UserData alloc]init];
        data.seed = @"677745";
        data.email = @"random@gmail.com";
        data.gender = @"male";
        data.name = @"test user";
        data.age = 29;
        data.dob = @"Today";
        
        [[UserDataManager sharedInstance] cacheUser:data withCompletionBlock:^(BOOL isSuccess) {
             XCTAssertTrue(isSuccess);
            [[UserDataManager sharedInstance] getUserListFromCacheWithCompletionBlock:^(NSArray<UserData *> * _Nullable list) {
                XCTAssertNotNil(list);
                [onCompleteExpectation fulfill];
            }];
        }];
        
        NSLog(@"Current user’s home directory is %@", NSHomeDirectory());
        
    });
    
    [self waitForExpectations:[NSArray arrayWithObjects:onCompleteExpectation, nil] timeout:100];
}



- (void)test_004_deleteuser {
    __block XCTestExpectation * onCompleteExpectation = [self expectationWithDescription:@"onComplete"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        UserData *data = [[UserData alloc]init];
        data.seed = @"677745";
        data.email = @"random@gmail.com";
        data.gender = @"male";
        data.name = @"test user";
        data.age = 29;
        data.dob = @"Today";
        
        [[UserDataManager sharedInstance] cacheUser:data withCompletionBlock:^(BOOL isSuccess) {
            XCTAssertTrue(isSuccess);
            [[UserDataManager sharedInstance] deleteUser:data withCompletionBlock:^(BOOL isSuccess) {
                XCTAssertTrue(isSuccess);
                [onCompleteExpectation fulfill];
            }];
        }];
    });
    [self waitForExpectations:[NSArray arrayWithObjects:onCompleteExpectation, nil] timeout:100];
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



@end
