//
//  IBENewsReaderAppDelegate.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsTabBarViewController.h"
#import "MBProgressHUD.h"
#import "LoginManager.h"
#import "UILoginView.h"
#import "UIAddPayView.h"
#import "LoadingView.h"
#import "AddPayManager.h"

@interface IBENewsReaderAppDelegate : NSObject <UIApplicationDelegate, DidLoginDelegate, UIAlertViewDelegate> {
    UIWindow *window;
	NewsTabBarViewController *newsTabBarViewController;
	MBProgressHUD *loadingView;
	LoginManager *loginManager;
	AddPayManager *addPayManager;
	UILoginView *loginView;
	UIAddPayView *addPayView;
	
	LoadingView *mainLoadingView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NewsTabBarViewController *newsTabBarViewController;
@property (nonatomic, retain) LoginManager *loginManager;
@property (nonatomic, retain) UILoginView *loginView;
@property (nonatomic, retain) UIAddPayView *addPayView;
@property (nonatomic, retain) IBOutlet LoadingView *mainLoadingView;

- (void)displayNewView:(UIView *)viewToDisplay;
- (void)goToNewsTabBarViewController;
- (void)showLoading:(BOOL)show withText:(NSString*)message;
- (void)showLoginForm; 
- (void)showAddPayForm; 
- (BOOL)validateForPaidUser;

@end
