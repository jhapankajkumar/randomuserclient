//
//  UserTableViewCell.h
//  RandomUserApp
//
//  Created by Gyan on 15/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserData;
@interface UserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UILabel *genderLbl;


-(void)setData:(UserData*)data;
@end
