//
//  SettingIndustryCellView.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIndustrySetting.h"

@interface SettingIndustryCellView : UITableViewCell {
	IBOutlet UILabel *industryName;
	IBOutlet UIButton *checkButton;
	NSString *industryId;
	bool isSelected;
}

@property(retain,nonatomic) IBOutlet UILabel *industryName;
@property(retain,nonatomic) IBOutlet UIButton *checkButton;
@property(retain,nonatomic) NSString *industryId;

-(void)setIsSelected:(bool)isSelected;

-(IBAction)checkButtonClick:sender;

@end
