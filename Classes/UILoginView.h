//
//  UILoginView.h
//  CustomAlert
//
//  Created by William Chu on 2010/12/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginManager.h"
#import "AddPayManager.h"
#import "MBProgressHUD.h"
#import "UILoginFailDelegate.h"

@interface UILoginView : UIAlertView <UIAlertViewDelegate, UIWebViewDelegate, DidLoginDelegate, UITextFieldDelegate> {
	UITextField *idTextField;
	UITextField *passwordTextField;
	UITextField *addPayTextField;
	
	UILabel *idLabel;
	UILabel *passwordLabel;
	UILabel *addPayLabel;
	
	UIWebView *registerAccountButton;
	UIWebView *forgetPasswordButton;
	
	LoginManager *loginManager;	
	AddPayManager *addPayManager;
	
	@private
	UILoginFailDelegate *failDelegate;
}

@property (nonatomic,retain) UITextField *idTextField;
@property (nonatomic,retain) UITextField *passwordTextField;
@property (nonatomic,retain) UITextField *addPayTextField;
@property (nonatomic,retain) UILoginFailDelegate *failDelegate;
@property (nonatomic,retain) LoginManager *loginManager;	
@property (nonatomic,retain) AddPayManager *addPayManager;

-(void)showResultDialogWithTitle:(NSString*)title message:(NSString*)message showAgain:(bool)show;
-(void)doLogin:(User*)user;
-(void)doLoginAndPay:(User*)user withPayCode:(NSString*)payCode;
@end
