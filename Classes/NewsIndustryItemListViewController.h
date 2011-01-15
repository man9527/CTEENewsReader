//
//  NewsIndustryItemListViewController.h
//  IBENewsReader
//
//  Created by William Chu on 2011/1/4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIndustrySetting.h"

@interface NewsIndustryItemListViewController : UITableViewController <UINavigationControllerDelegate> {
	UserIndustrySetting *userIndustrySetting;
	NSArray *selectedIndustry;
}
@property (nonatomic,retain) UserIndustrySetting *userIndustrySetting;
@property (nonatomic,retain) NSArray *selectedIndustry;

@end
