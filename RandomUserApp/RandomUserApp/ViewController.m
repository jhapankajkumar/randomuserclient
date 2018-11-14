//
//  ViewController.m
//  RandomUserApp
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "ViewController.h"
#import <RandomUser/RandomUser.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getListOfuser];
}

-(void)getListOfuser {
    [[UserDataManager sharedInstance]getUserListWithSeed:@"002" gender:@"male" resultCount:10 withCompletionBlock:^(NSArray<UserDetails *> *users, NSError *error) {
        NSLog(@"%@",users);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
