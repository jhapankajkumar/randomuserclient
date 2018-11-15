//
//  MainViewController.h
//  RandomUserApp
//
//  Created by Pankaj Jha on 16/11/18.
//  Copyright © 2018 Pankaj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>
- (IBAction)showLeftMenuPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@end

