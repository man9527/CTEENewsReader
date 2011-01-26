//
//  SettingHomeViewController.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingHomeViewController.h"
#import "LoginManager.h"
#import "UserService.h"
#import "SettingIndustryViewController.h"
#import "IBENewsReaderAppDelegate.h"
#import "URLManager.h"
#import "User.h"
@implementation SettingHomeViewController

@synthesize addPayButton, authButton, subscribeButton, changeDataButton, expiredDateLeftLabel, expiredDateLabel, user;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView) name:@"AuthenticationEvent" object:nil];
	
	[self determineLoginStatus];
	selectedImage = [UIImage imageNamed:@"listbg_320_44-1.png"];
	selectedBackground = [[UIImageView alloc] initWithImage:selectedImage];
}

-(BOOL)determineLoginStatus
{
	user = [UserService currentLogonUser];
	
	if (user!=nil)
	{
		return YES;
	}
	else {
		return NO;
	}
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)reloadView
{
	[self determineLoginStatus];
	[self.tableView reloadData];
}

-(void)addPayButtonClick
{
	NSString *message;
	
	if (user!=nil)
	{
		message = @"ShowAddPayForm";
		[[NSNotificationCenter defaultCenter] postNotificationName:message object:nil userInfo:nil];
	}
	//else {
	//	message = @"ShowLoginForm";
	//}

	//[[NSNotificationCenter defaultCenter] postNotificationName:message object:nil userInfo:nil];
}

-(void)authButtonClick
{
	if (user!=nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"帳號登出" message:@"確定嗎？"  delegate:self  cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
		[alert show];
		[alert release];
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoginForm" object:nil userInfo:nil];
	}	
}

-(void)changeDataButtonClick
{
	NSURL *url = [NSURL URLWithString:[URLManager getModifyDataURLForUser:user]];
	[[UIApplication sharedApplication] openURL:url];	
}

-(void)subscribeButtonClick
{
	NSURL *url = [NSURL URLWithString:[URLManager getSubscribeURL]];
	[[UIApplication sharedApplication] openURL:url];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==1)
	{
		[UserService logoutCurrentLogonUser:user];
	}
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section==0)
	{
		return 2;
	}
	else
	{
		if (self.user) {
			return 2;
		}
		else {
			return 1;
		}
	}
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection: (NSInteger)section
{
	if (section==0)
	{
		return @"訂閱";
	}
	else
	{
		return @"使用者帳號";
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//cell.selectedBackgroundView = selectedBackground;
    }
    
	if (indexPath.section==0)
	{
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"輸入儲值碼";
				if (!self.user)
				{
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
				}
				else {
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				}

				break;
			case 1:
				cell.textLabel.text = @"前往訂閱";
				break;
			default:
				break;
		}
	}
	else {
		switch (indexPath.row) {
			case 0:
				if (self.user)
				{
					cell.textLabel.text = @"登出";
				}
				else {
					cell.textLabel.text = @"登入";
				}
			break;
			case 1:
				cell.textLabel.text = @"會員資料修改";
			break;
			default:
				break;
		}
	}
    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
	if (section==1 && user!=nil)
	{
		NSString *tmpStr = @"有效日期至：%@";
		return [NSString stringWithFormat:tmpStr, [user getExpireDateByString]];
	}
	else {
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section==0)
	{
		switch (indexPath.row) {
			case 0:
				[self addPayButtonClick];
				break;
			case 1:
				[self subscribeButtonClick];
				break;				
			default:
				break;
		}
	}
	else {
		switch (indexPath.row) {
			case 0:
				[self authButtonClick];
				break;
			case 1:
				[self changeDataButtonClick];
				break;				
			default:
				break;
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[selectedBackground release];
	
    [super dealloc];
}

@end
