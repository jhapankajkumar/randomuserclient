//
//  ViewController.h
//  RandomUserApp
//
//  Created by Gyan on 14/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RandomUser/RandomUser.h>

@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *listTableView;

@property (nonatomic,strong) NSArray *userList;
@property (nonatomic) BOOL isStoredUserList;
@end

