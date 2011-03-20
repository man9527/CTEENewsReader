//
//  UILoginView.m
//  CustomAlert
//
//  Created by William Chu on 2010/12/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UILoginView.h"
#import "MBProgressHUD.h"
#import "IBENewsReaderAppDelegate.h"
#import "UILoginFailDelegate.h"
#import "URLManager.h"
#import "AddPayManager.h"

@implementation UILoginView
@synthesize idTextField, passwordTextField, addPayTextField, failDelegate, loginManager, addPayManager;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		//loginManager = [[LoginManager alloc] init];
		//addPayManager = [[AddPayManager alloc] init];

		failDelegate = [[UILoginFailDelegate alloc]init];

		idLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		idLabel.backgroundColor = [UIColor clearColor];
		idLabel.text = @"帳號";
		idLabel.textColor = [UIColor whiteColor];
		idLabel.font = [UIFont systemFontOfSize:20];

		idTextField = [[UITextField alloc] initWithFrame:CGRectZero]; 
		[idTextField setBorderStyle:UITextBorderStyleRoundedRect];
		idTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		idTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
		passwordLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		passwordLabel.backgroundColor = [UIColor clearColor];
		passwordLabel.text = @"密碼";
		passwordLabel.textColor = [UIColor whiteColor];
		passwordLabel.font = [UIFont systemFontOfSize:20];

		passwordTextField = [[UITextField alloc] initWithFrame:CGRectZero]; 
		[passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
		passwordTextField.secureTextEntry = YES;
		
		addPayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		addPayLabel.backgroundColor = [UIColor clearColor];
		addPayLabel.text = @"儲值碼";
		addPayLabel.textColor = [UIColor whiteColor];
		addPayLabel.font = [UIFont systemFontOfSize:20];

		addPayTextField = [[UITextField alloc] initWithFrame:CGRectZero]; 
		addPayTextField.placeholder = @"非必要欄位";
		addPayTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		addPayTextField.keyboardType = UIKeyboardTypeNumberPad;
		[addPayTextField setBorderStyle:UITextBorderStyleRoundedRect];
		addPayTextField.clearButtonMode = UITextFieldViewModeAlways;
		
		registerAccountButton = [[UIWebView alloc] initWithFrame:CGRectZero];
		[registerAccountButton loadHTMLString:[NSString stringWithFormat: @"<a href='%@'>操作手冊</a>", [URLManager getManualURL]] baseURL:nil];
		[registerAccountButton setOpaque:NO];
		registerAccountButton.backgroundColor = [UIColor clearColor];
		registerAccountButton.delegate = self;

		forgetPasswordButton = [[UIWebView alloc] initWithFrame:CGRectZero];
		[forgetPasswordButton loadHTMLString:[NSString stringWithFormat: @"<a href='%@'>忘記密碼</a>", [URLManager getForgetPasswordURL]] baseURL:nil];
		[forgetPasswordButton setOpaque:NO];
		forgetPasswordButton.backgroundColor = [UIColor clearColor];
		forgetPasswordButton.delegate = self;
		
		[self addSubview:idLabel];
		[self addSubview:idTextField];
		[self addSubview:passwordLabel];
		[self addSubview:passwordTextField];
		[self addSubview:addPayLabel];
		[self addSubview:addPayTextField];
		[self addSubview:registerAccountButton];
		[self addSubview:forgetPasswordButton];
	}
	return self;
}

- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles, ... 
{	
	if ( self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles,nil])
	{
		self.delegate = self;
		self.tag = 1000;
	}
	return self;
}

- (void)setFrame:(CGRect)rect {
	NSLog(@"draw rect again");
	[super setFrame:CGRectMake(0, 0, rect.size.width, 230)];
	// [super setFrame:CGRectMake(0, 0, rect.size.width, 260)];
	self.center = CGPointMake(160.0, 150.0);
}

- (void)layoutSubviews {
	NSLog(@"in layout sub views");
	[self setFrame:self.frame];
	
	CGFloat buttonTop = 0.0;
	
	for (UIView *view in self.subviews) {
		if ([[[view class] description] isEqualToString:@"UIThreePartButton"]) {
			view.frame = CGRectMake(view.frame.origin.x, self.bounds.size.height - view.frame.size.height - 15, view.frame.size.width, view.frame.size.height);
			buttonTop = view.frame.origin.y;
		}
	}

	buttonTop -= 35;

	registerAccountButton.frame = CGRectMake(48, buttonTop, 100, 30);
	forgetPasswordButton.frame = CGRectMake(138, buttonTop, 100, 30);
	
	//buttonTop -= 30;
	//addPayLabel.frame = CGRectMake(12, buttonTop, self.frame.size.width - 52, 30);
	//addPayTextField.frame = CGRectMake(80, addPayLabel.frame.origin.y, 185, addPayLabel.frame.size.height);
	
	buttonTop -= 35;
	passwordLabel.frame = CGRectMake(20, buttonTop, self.frame.size.width - 52, 30);
	passwordTextField.frame = CGRectMake(70, passwordLabel.frame.origin.y, 185, passwordLabel.frame.size.height);

	buttonTop -= 35;
	idLabel.frame = CGRectMake(20, buttonTop, self.frame.size.width - 52, 30);
	idTextField.frame = CGRectMake(70, idLabel.frame.origin.y, 185, idLabel.frame.size.height);

	//[idTextField becomeFirstResponder];
}

#pragma mark intercept click on UIWebView
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	else {
		return YES;
	}
}

-(void)doLogin:(User*)user
{
	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showLoading:TRUE withText:@"登入中..."];
	
	[loginManager login:user];
}

-(void)doLoginAndPay:(User*)user withPayCode:(NSString*)payCode
{
	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showLoading:TRUE withText:@"儲值中"];
	
	[addPayManager addPay:user withPayCode:payCode];
}

#pragma mark handle button click event
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag==1000)
	{
		if (buttonIndex==1)
			{
				if ([self checkInput])
				{
					User *user = [[[User alloc] init] autorelease];
					user.username = idTextField.text;
					user.password = passwordTextField.text;
					
					[self doLogin:user];
				}
			}
	}
}

#pragma mark handle login event
- (void)didLoginResult:(bool)isSuccessful andReason:(NSString*)reason For:(User*) u
{
	NSLog(@"in login result");

	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showLoading:FALSE withText:nil];

	if (!isSuccessful)
	{
		[self showResultDialogWithTitle:@"登入失敗" message:reason showAgain:YES];
	}
	else {
		if (addPayTextField.text!=nil && ![addPayTextField.text isEqual:@""])
		{
			NSLog(@"add pay text %@", addPayTextField.text);
			[self doLoginAndPay:u withPayCode:addPayTextField.text];
		}
		else {
			[self showResultDialogWithTitle:@"登入成功" message:reason  showAgain:NO];
		}
	}
}

/*
- (void)didAddPayResult:(int)status andReason:(NSString*)reason For:(User*) u
{
	NSLog(@"in add pay result");

	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showLoading:FALSE withText:nil];
	
	NSString *title;
	
	if (status==1)
		title = @"登入失敗";
	else if (status==4)
		title = @"儲值失敗";
	
	if (status==1 || status==4)
	{
		[self showResultDialogWithTitle:title message:reason showAgain:YES];
		// [self release];
	}
	else {
		[self doLogin:u];
	}

}*/

- (bool)checkInput
{
	NSString *username = idTextField.text;
	NSString *password = passwordTextField.text;
	
	if (username==nil || [username isEqual:@""])
	{
		[self showResultDialogWithTitle:@"登入失敗" message:@"請輸入使用者名稱" showAgain:YES];

		return FALSE;
	}
	if (password==nil || [password isEqual:@""])
	{
		[self showResultDialogWithTitle:@"登入失敗" message:@"請輸入密碼" showAgain:YES];
       
		return FALSE;
	}
	
	return TRUE;
}

-(void)showResultDialogWithTitle:(NSString*)title message:(NSString*)message showAgain:(bool)show
{
	UILoginFailDelegate *fail;
	
	if (show)
	{ 
		fail = failDelegate;
	}
	else {
		fail = nil;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message  delegate:fail  cancelButtonTitle:nil otherButtonTitles:@"確定", nil];
	[alert show];
	[alert release];
}


- (void)show
{
	[super show];
	passwordTextField.text=@"";
}

-(void) dealloc
{
	[idTextField release];
	[passwordTextField release];
	[addPayTextField release];
	
	[idLabel release];
	[passwordLabel release];
	[addPayLabel release];
	
	[registerAccountButton release];
	[forgetPasswordButton release];
	
	[loginManager release];	
	[addPayManager release];
	[failDelegate release];
	
	[super dealloc];
}

@end
