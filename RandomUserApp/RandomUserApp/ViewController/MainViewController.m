//
//  MainViewController.m
//  RandomUserApp
//
//  Created by Pankaj Jha on 16/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "MainViewController.h"
#import "MFSideMenu.h"
#import <RandomUser/RandomUser.h>
#import "ViewController.h"
#import "UserDetailViewController.h"

@interface MainViewController () <UITextFieldDelegate> {
    NSArray *userList;
}
@property (weak, nonatomic) IBOutlet UITextField *userId;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *multipleUserCount;
@property (weak, nonatomic) IBOutlet UIButton *queryButton;
@property (strong, nonatomic) NSArray *genderList;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.genderTextField.inputView = self.pickerView;
    // Do any additional setup after loading the view.
    [self initialSetup];
}

-(void)initialSetup {
    self.genderList = @[@"Male",
                        @"Female"];
    
    self.pickerView.hidden = true;
    self.loadingView.hidden = true;
}
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.genderList.count;
}


- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.genderList objectAtIndex:row];
}

- (IBAction)showLeftMenuPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.genderTextField.text = [self.genderList objectAtIndex:row];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.genderTextField]) {
        [self.view endEditing:true];
        //[textField becomeFirstResponder];
    }
    return true;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.pickerView.hidden = true;
    if ([textField isEqual:self.genderTextField]) {
        self.pickerView.hidden = false;
        [textField resignFirstResponder];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [textField resignFirstResponder];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return true;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return true;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
    self.pickerView.hidden = true;
}
- (IBAction)queryUsers:(id)sender {
    self.loadingView.hidden = false;
    self.activityIndicatorView.hidden = false;
    [self.activityIndicatorView startAnimating];
    [self.view endEditing:true];
    [[UserDataManager sharedInstance] getUserListWithSeed:self.userId.text gender:self.genderTextField.text resultCount:[self.multipleUserCount.text integerValue] withCompletionBlock:^(NSArray<UserData *> * _Nullable users, NSError * _Nullable error) {
        [self.activityIndicatorView stopAnimating];
        self.loadingView.hidden = true;
        
        if (error == nil) {
            self->userList = users;
            if (users.count > 1) {
                [self performSegueWithIdentifier:@"toUserListVC" sender:sender];
            }
            else {
                [self performSegueWithIdentifier:@"fromQueryToUserDetail" sender:sender];
            }
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toUserListVC"]) {
        ViewController *viewController = (ViewController*) segue.destinationViewController;
        viewController.userList = userList;
    }
    else if ([segue.identifier isEqualToString:@"fromQueryToUserDetail"]){
        UserDetailViewController *detailVc = (UserDetailViewController *)segue.destinationViewController;
        [detailVc setUserDetail:[userList objectAtIndex:0]];
    }
}



@end
