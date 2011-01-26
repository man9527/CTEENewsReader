//
//  UIAddPayView.h
//  IBENewsReader
//
//  Created by William Chu on 2010/12/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddPayManager.h"
#import "UIAddPayFailDelegate.h"

@interface UIAddPayView : UIAlertView<UIAlertViewDelegate, DidAddPayDelegate> {
	UITextField *addPayTextField;
	UILabel *addPayLabel;
	
	AddPayManager *addPayManager;
	UIAddPayFailDelegate *failDelegate;
}

@property (nonatomic,retain) UITextField *addPayTextField;
@property (nonatomic,retain) UIAddPayFailDelegate *failDelegate;
@property (nonatomic,retain) AddPayManager *addPayManager;

-(void)showResultDialogWithTitle:(NSString*)title message:(NSString*)message showAgain:(bool)show;

@end
