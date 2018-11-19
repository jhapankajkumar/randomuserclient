//
//  UserDetailViewController.h
//  RandomUserApp
//
//  Created by Gyan on 15/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RandomUser/RandomUser.h>

@protocol UserActionDelegate

-(void)notifyDeleteEvenForUserData:(UserData *)data;

@end

@interface UserDetailViewController : UIViewController

-(void)setUserDetail:(UserData*)userData;
@property (nonatomic) BOOL isStoredUserDetail;
@property (nonatomic,weak) id <UserActionDelegate> delegate;

@end
