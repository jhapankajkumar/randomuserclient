//
//  UserTableViewCell.m
//  RandomUserApp
//
//  Created by Gyan on 15/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import "UserTableViewCell.h"
#import <RandomUser/RandomUser.h>

@implementation UserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(UserData*)data {
    self.nameLbl.text = [data.name capitalizedString];
    self.emailLbl.text = data.email;
    self.genderLbl.text = data.gender;
}
@end
