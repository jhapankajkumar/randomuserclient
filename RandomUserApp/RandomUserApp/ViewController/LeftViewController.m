//
//  LeftViewController.m
//  RandomUserApp
//
//  Created by Pankaj Jha on 15/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "LeftViewController.h"
#import "MFSideMenu.h"
@interface LeftViewController ()
@property (strong, nonatomic) NSArray *titlesArray;
@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titlesArray = @[@"Home",
                         @"View Stored User",
                         @"Settings"];
}

- (IBAction)showLeftMenuPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesArray.count ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
 
    UILabel *label = [cell viewWithTag:1001];
    label.text = [self.titlesArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}

@end
