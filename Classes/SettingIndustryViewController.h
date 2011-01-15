//
//  SettingIndustryViewController.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIndustrySetting.h"

@protocol AddSelectedIndustryDone
@required
- (void)AddSelectedIndustryDone;
@end

@interface SettingIndustryViewController : UITableViewController {
	UserIndustrySetting *userIndustrySetting;
	NSArray *nonSelectedIndustry;
	NSArray *selectedIndustry;
}

@property (nonatomic,retain) NSArray *nonSelectedIndustry;
@property (nonatomic,retain) NSArray *selectedIndustry;
@property (nonatomic,retain) UserIndustrySetting *userIndustrySetting;

@end
