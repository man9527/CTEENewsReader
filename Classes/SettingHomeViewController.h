//
//  SettingHomeViewController.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface SettingHomeViewController : UITableViewController <UIAlertViewDelegate> {
	User *user;
}

@property (nonatomic,retain) IBOutlet UIButton* addPayButton;
@property (nonatomic,retain) IBOutlet UIButton* authButton;
@property (nonatomic,retain) IBOutlet UIButton* subscribeButton;
@property (nonatomic,retain) IBOutlet UIButton* changeDataButton;

@property (nonatomic,retain) IBOutlet UILabel* expiredDateLabel;
@property (nonatomic,retain) IBOutlet UILabel* expiredDateLeftLabel;

@property (nonatomic,retain) User* user;

-(void)addPayButtonClick;
-(void)authButtonClick;
-(void)changeDataButtonClick;
-(void)subscribeButtonClick;

-(BOOL)determineLoginStatus;
@end
