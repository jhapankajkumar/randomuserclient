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
    self.dobLblb.text = [self getDateOfBirth:self.user.dob];
    if (self.isStoredUserDetail) {
        [self.storeButton setTitle:@"Delete" forState:UIControlStateNormal];
    }
}

-(NSString *)getDateOfBirth:(NSString *)dob {
    //2016-04-22 16:30:36 +0000
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate * convrtedDate = [formatter dateFromString:dob];
    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *dateString = [formatter stringFromDate:convrtedDate];
    return dateString;
}
-(void)setUserDetail:(UserData*)userData {
    self.user = userData;
}

- (IBAction)storeUserToCache:(id)sender {
    self.storeButton.enabled = false;
    //Delete user
    if (self.isStoredUserDetail) {
        [[UserDataManager sharedInstance] deleteUser:self.user withCompletionBlock:^(BOOL isSuccess, RandomUserError * _Nullable error) {
            if (!isSuccess) {
                self.storeButton.enabled = true;
                [self showAlertWithMessage:error.errorMessage];
            }
            else{
                [self.delegate notifyChangeEvent];
                [self.navigationController popViewControllerAnimated:true];
            }
        }];
    }
    //Save User
    else{
        [[UserDataManager sharedInstance] cacheUser:self.user withCompletionBlock:^(BOOL isSuccess, RandomUserError * _Nullable error)  {
            NSLog(@"%d",isSuccess);
            if (!isSuccess) {
                self.storeButton.enabled = true;
                [self showAlertWithMessage:error.errorMessage];
            }
            else {
                [self.storeButton setTitle:@"Stored" forState:UIControlStateNormal];
            }
            
        }];
    }
    
}

-(void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
