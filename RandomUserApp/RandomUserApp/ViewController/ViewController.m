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
#import "UserDetailViewController.h"

@interface ViewController () {
    NSIndexPath *selectedIndexPath;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initialSetup];
}


-(void)initialSetup {
    self.listTableView.estimatedRowHeight =  100;
    self.listTableView.rowHeight = UITableViewAutomaticDimension;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self performSegueWithIdentifier:@"fromListToUserDetail" sender:selectedIndexPath];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"fromListToUserDetail"]){
        UserDetailViewController *detailVc = (UserDetailViewController *)segue.destinationViewController;
        [detailVc setUserDetail:[self.userList objectAtIndex:selectedIndexPath.row]];
    }
}


@end
