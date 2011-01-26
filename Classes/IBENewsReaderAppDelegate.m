//
//  IBENewsReaderAppDelegate.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "IBENewsReaderAppDelegate.h"
#import "User.h"
#import "UserService.h"
#import "NewsTabBarViewController.h"
#import "MBProgressHUD.h"
#import "UILoginView.h"
#import "UIAddPayView.h"
#import "URLManager.h"

@implementation IBENewsReaderAppDelegate

@synthesize window,newsTabBarViewController, loginManager, loginView, mainLoadingView, addPayView;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	[window addSubview:mainLoadingView.view];
	
	newsTabBarViewController= [[NewsTabBarViewController alloc] init];
	
	loginManager = [[LoginManager alloc] init];
	addPayManager = [[AddPayManager alloc] init];

	loginView = [[UILoginView alloc] initWithTitle:@"會員登入" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"登入", nil];
	loginView.loginManager = loginManager;
	loginView.addPayManager = addPayManager;
	loginManager.delegate = loginView;

	addPayView = [[UIAddPayView alloc] initWithTitle:@"請輸入儲值碼" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"儲值", nil];
	addPayView.addPayManager = addPayManager;
	addPayManager.delegate = addPayView;
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginForm) name:@"ShowLoginForm" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddPayForm) name:@"ShowAddPayForm" object:nil];
	
	[UserService loadCacheUserAsLogonUser];
	User *u = [UserService currentLogonUser];
	
	// if user/passwd cached, try login and regardless the result
	if (u != NULL){
		LoginManager *tempManager = [[[LoginManager alloc] init] autorelease];
		tempManager.delegate=self;
		[tempManager login:u];
	}
	else {
		[self goToNewsTabBarViewController];
	}

	[window makeKeyAndVisible];
	
	return YES;
}

// DidLoginDelegate
- (void)didLoginResult:(bool) isSuccessful andReason:(NSString*)reason For:(User*) u
{
	[self goToNewsTabBarViewController];
}

- (void)displayNewView:(UIView *)viewToDisplay {
	// remove all views
	for( UIView* view in [window subviews] ) {
	 	[view removeFromSuperview];
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:window cache:YES];
	[window addSubview:viewToDisplay];	
	[UIView commitAnimations];
}


- (void)goToNewsTabBarViewController
{
	[self displayNewView:newsTabBarViewController.view];
}

- (void)showLoginForm // :(NSNotification *)notification
{
	[loginView show];
	[loginView.idTextField becomeFirstResponder];
}

- (void)showAddPayForm // :(NSNotification *)notification
{
	[addPayView show];
	[addPayView.addPayTextField becomeFirstResponder];
}

- (void)showLoading:(BOOL)show withText:(NSString*)message
{
	if (show)
	{
		if (loadingView == nil)
		{
			loadingView = [[MBProgressHUD alloc] initWithWindow:window];
		}
		[window addSubview:loadingView];
		loadingView.labelText = message;	
		[loadingView show:TRUE];
	}
	else {
		[loadingView hide:TRUE];
	}

}

- (BOOL)validateForPaidUser
{
	User* user = [UserService currentLogonUser];
	
	if (user==nil || ![user isPaid]) 
	{
		if (user==nil)
		{
			NSString *message = @"本服務僅提供給付費有效會員使用，請先登入";
		
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您尚未登入" message:message  delegate:self  cancelButtonTitle:@"僅試閱" otherButtonTitles:@"會員登入", nil];
			alert.tag=1000;
			[alert show];
			[alert release];		
		}
		else 
		{
			NSString *message = @"本服務僅提供給付費有效會員使用，請前往訂閱";
				
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"想要看更多內容？" message:message  delegate:self  cancelButtonTitle:@"僅試閱" otherButtonTitles:@"前往訂閱", nil];
			alert.tag=2000;
			[alert show];
			[alert release];		
		}
		
		return NO;
	}
	else {
		return YES;
	}

}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag==1000)
	{
		if (buttonIndex==1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoginForm" object:nil userInfo:nil];
		}
	}
	else if (alertView.tag==2000)
	{
		if (buttonIndex==1) {
			NSURL *url = [NSURL URLWithString:[URLManager getSubscribeURL]];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
}

- (void)dealloc {
	[newsTabBarViewController release];
	[loginManager release];
    [window release];
	[loadingView release];
	[loginView release];
	[addPayView release];
	[mainLoadingView release];
	
	[super dealloc];
}


@end
