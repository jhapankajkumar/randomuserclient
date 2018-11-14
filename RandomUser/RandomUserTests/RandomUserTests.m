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


-(void)test_001_getuserList {
    __block XCTestExpectation * onCompleteExpectation = [self expectationWithDescription:@"onComplete"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSLog(@"Current user’s home directory is %@", NSHomeDirectory());
        [[UserDataManager sharedInstance] getUserListWithSeed:@"002" gender:@"female" resultCount:1000 withCompletionBlock:^(NSArray *users, NSError *error) {
            XCTAssert(true);
            [onCompleteExpectation fulfill];
        }];
    });
    
    [self waitForExpectations:[NSArray arrayWithObjects:onCompleteExpectation, nil] timeout:100];
}

-(void)test_002_savedUser {
    __block XCTestExpectation * onCompleteExpectation = [self expectationWithDescription:@"onComplete"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSLog(@"Current user’s home directory is %@", NSHomeDirectory());
        [[UserDataManager sharedInstance]getStoredUserFromCacheWithCompletionBlock:^(NSArray<UserDetail *> *list) {
            NSLog(@"%@",list);
            [onCompleteExpectation fulfill];
        }];
    });
    
    [self waitForExpectations:[NSArray arrayWithObjects:onCompleteExpectation, nil] timeout:100];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
