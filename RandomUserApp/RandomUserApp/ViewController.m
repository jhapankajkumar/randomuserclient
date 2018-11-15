//
//  ViewController.m
//  RandomUserApp
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "ViewController.h"
#import <RandomUser/RandomUser.h>
#import "UserTableViewCell.h"

@interface ViewController ()
@property (nonatomic,strong) NSMutableArray *userList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getListOfuser];
}


-(void)initialSetup {
    self.userList = [[NSMutableArray alloc]init];
    self.listTableView.estimatedRowHeight =  100;
    self.listTableView.rowHeight = UITableViewAutomaticDimension;
}
-(void)getListOfuser {
    
    [[UserDataManager sharedInstance]getUserListWithSeed:@"002" gender:@"male" resultCount:20 withCompletionBlock:^(NSArray<UserData *> * _Nullable users, NSError * _Nullable error) {
        if (error == nil) {
            self.userList = users;
            [self.listTableView reloadData];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma -mark TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UserTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListCell"];
    }
    UserData *data = [self.userList objectAtIndex:indexPath.row];
    [cell setData:data];
    return cell;
}

@end
