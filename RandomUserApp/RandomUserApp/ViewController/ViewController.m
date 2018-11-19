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

@interface ViewController ()<UserActionDelegate> {
    NSIndexPath *selectedIndexPath;
    UIButton *storeDeleteAllButton;
    UIView *loadingView;
    UIActivityIndicatorView *loadingIndicatore;
    NSInteger pageNo;
    NSInteger pageSize;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initialSetup];
}


- (void)setupLoader {
    
    loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    loadingView.backgroundColor = [UIColor blackColor];
    loadingView.alpha = 0.6;
    
    loadingIndicatore = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingIndicatore.frame = CGRectMake(0, 0, 30, 30);
    loadingIndicatore.center = loadingView.center;
    
    [loadingView addSubview:loadingIndicatore];
    loadingView.hidden = true;
    
    [self.view addSubview:loadingView];
    [self.view bringSubviewToFront:loadingView];
}

-(void)showLoader{
    loadingView.hidden = false;
    loadingIndicatore.hidden = false;
    [loadingIndicatore startAnimating];
}

- (void)hideLoader {
    [loadingIndicatore stopAnimating];
    loadingIndicatore.hidden =  true;
    loadingView.hidden = true;
}

- (void)setupBarButtonItem {
    CGRect frameimg = CGRectMake(15,5, 60,25);
    storeDeleteAllButton = [[UIButton alloc] initWithFrame:frameimg];
    
    [storeDeleteAllButton addTarget:self action:@selector(storeDeleteAll:)
                   forControlEvents:UIControlEventTouchUpInside];
    [storeDeleteAllButton setShowsTouchWhenHighlighted:YES];
    [storeDeleteAllButton setTitle:@"Store All" forState:UIControlStateNormal];
    [storeDeleteAllButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    UIBarButtonItem *barButton =[[UIBarButtonItem alloc] initWithCustomView:storeDeleteAllButton];
    if (self.isStoredUserList) {
        [storeDeleteAllButton setTitle:@"Delete All" forState:UIControlStateNormal];
        [storeDeleteAllButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = barButton;
}

-(void)initialSetup {
    self.listTableView.estimatedRowHeight =  100;
    pageNo = 1;
    pageSize = 20;
    self.listTableView.rowHeight = UITableViewAutomaticDimension;
    [self setupLoader];
    [self setupBarButtonItem];
    if (self.isStoredUserList) {
        [self getStoredUserList];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
}

- (void)getStoredUserList {
    [self showLoader];
    [[UserDataManager sharedInstance] getUserListFromCacheWithPageNo:pageNo pageSize:pageSize withCompletionBlock:^(NSArray<UserData *> * _Nullable list, RandomUserError * _Nullable error)  {
        [self hideLoader];
        self.userList = list;
        [self.listTableView reloadData];
    }];
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Need to expose one more api which gets the total no of records present in data base
    if (indexPath.row == (pageNo * pageSize) - 5 ) {
        pageNo ++;
        NSLog(@"Page No  = %ld",(long)pageNo);
        [[UserDataManager sharedInstance] getUserListFromCacheWithPageNo:pageNo pageSize:pageSize withCompletionBlock:^(NSArray<UserData *> * _Nullable list, RandomUserError * _Nullable error)  {
            NSLog(@"Records  = %lu",list.count);
            if (error == nil) {
                [self.userList addObjectsFromArray:list];
                [self.listTableView reloadData];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"fromListToUserDetail"]){
        UserDetailViewController *detailVc = (UserDetailViewController *)segue.destinationViewController;
        [detailVc setUserDetail:[self.userList objectAtIndex:selectedIndexPath.row]];
         detailVc.title = @"User Detail";
         if (self.isStoredUserList) {
             detailVc.isStoredUserDetail = true;
         }
         detailVc.delegate =  self;
    }
}


-(void)storeDeleteAll:(UIButton *)sender {
    storeDeleteAllButton.enabled = false;
    if (self.userList.count > 0) {
        [self showLoader];
        
        //Delete all
        if (self.isStoredUserList) {
            [[UserDataManager sharedInstance] deleteUserList:self.userList withCompletionBlock:^(BOOL isSuccess, RandomUserError * _Nullable error) {
                [self hideLoader];
                if (!isSuccess) {
                    self->storeDeleteAllButton.enabled = true;
                    [self showAlertWithMessage:error];
                }
                else{
                    
                    pageNo = 1;
                    NSLog(@"Page No  = %ld",(long)self->pageNo);
                    //Load the new set of records if exists
                    [[UserDataManager sharedInstance] getUserListFromCacheWithPageNo:self->pageNo pageSize:self->pageSize withCompletionBlock:^(NSArray<UserData *> * _Nullable list, RandomUserError * _Nullable error)  {
                        NSLog(@"Records  = %lu",list.count);
                        if (error == nil) {
                            if (list.count > 0) {
                                self->storeDeleteAllButton.enabled = true;
                                //remove deleted records
                                [self.userList removeAllObjects];
                                
                                //add new records
                                [self.userList addObjectsFromArray:list];
                                
                                //reload table
                                [self.listTableView reloadData];
                            }
                            //if no records found return to previous screen
                            else {
                                [self.navigationController popViewControllerAnimated:true];
                            }
                            
                        }
                    }];
                    
                }
            }];
        }
        //Store all
        else{
            [[UserDataManager sharedInstance]cacheUserList:self.userList withCompletionBlock:^(BOOL isSuccess, RandomUserError * _Nullable error) {
                [self hideLoader];
                if (!isSuccess) {
                    self->storeDeleteAllButton.enabled = true;
                    [self showAlertWithMessage:error];
                }
                else {
                    [self->storeDeleteAllButton setTitle:@"Stored" forState:UIControlStateNormal];
                }
            }];
        }
    }
}

-(void)showAlertWithMessage:(RandomUserError *)error  {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:error.errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)notifyDeleteEvenForUserData:(UserData *)data{
    [self.userList removeObject:data];
    [self.listTableView reloadData];
}

@end
