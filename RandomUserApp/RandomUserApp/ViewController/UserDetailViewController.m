//
//  UserDetailViewController.m
//  RandomUserApp
//
//  Created by Gyan on 15/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "UserDetailViewController.h"
#import <RandomUser/RandomUser.h>

@interface UserDetailViewController ()
@property (nonatomic,strong)UserData *user;
@property (weak, nonatomic) IBOutlet UILabel *userId;
@property (weak, nonatomic) IBOutlet UILabel *namelbl;
@property (weak, nonatomic) IBOutlet UILabel *genderLbl;
@property (weak, nonatomic) IBOutlet UILabel *ageLbl;
@property (weak, nonatomic) IBOutlet UILabel *dobLblb;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;

@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [self fillData];
}

-(void)fillData  {
    self.emailLbl.text = self.user.email;
    self.namelbl.text = [self.user.name capitalizedString];
    self.genderLbl.text = [self.user.gender capitalizedString];
    self.ageLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.user.age];
    self.userId.text = self.user.seed;
    self.dobLblb.text = self.user.dob;
}
    
-(void)setUserDetail:(UserData*)userData {
    self.user = userData;
}

- (IBAction)storeUserToCache:(id)sender {
    self.storeButton.enabled = false;
    [[UserDataManager sharedInstance] cacheUser:self.user withCompletionBlock:^(BOOL isSuccess) {
        NSLog(@"%d",isSuccess);
        if (!isSuccess) {
            self.storeButton.enabled = true;
        }
    }];
}


@end
