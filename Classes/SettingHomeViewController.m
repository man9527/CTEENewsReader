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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView) name:@"AuthenticationEvent" object:nil];
	
	[self determineLoginStatus];

	NSDate *now = [NSDate date];
	LoginManager *tm = [[[LoginManager alloc] init] autorelease];
	
	switch ([user.invalidDate compare:now]) {
		case NSOrderedAscending:
		case NSOrderedSame:
			tm.delegate=self;
			[tm login:user];
			break;				
		default:
			break;
	}
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

- (void)didLoginResult:(bool)isSuccessful andReason:(NSString*)reason For:(User*) u
{
	if (isSuccessful)
	{
		[self.tableView reloadData];
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
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"請先登入" message:nil  delegate:nil  cancelButtonTitle:nil otherButtonTitles:@"確定", nil];
		[alert show];
		[alert release];		
	}

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
	NSURL *url;
	
	if (user!=nil)
	{
		url = [NSURL URLWithString:[URLManager getModifyDataURLForUser:user]];
	}else {
		url = [NSURL URLWithString:[URLManager getForgetPasswordURL]];
	}

	[[UIApplication sharedApplication] openURL:url];	
}

-(void)subscribeButtonClick
{
	NSURL *url = [NSURL URLWithString:[URLManager getManualURL]];
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
	return 2;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection: (NSInteger)section
{
	if (section==0)
	{
		return @"會員儲值";
	}
	else
	{
		if (!self.user)
		{
			return @"使用狀態";
		}
		else {
			return [@"使用狀態：" stringByAppendingString:self.user.username];
		}

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
    }
    
	if (indexPath.section==0)
	{
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"輸入儲值碼";
				if (!self.user)
				{
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					[cell.textLabel setTextColor:[UIColor colorWithRed:176.0/256.0 green:176.0/256.0 blue:176.0/256.0 alpha:1.0]];
				}
				else {
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					[cell.textLabel setTextColor:[UIColor blackColor]];
				}

				break;
			case 1:
				cell.textLabel.text = @"操作手冊";
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
				if (self.user)
				{
					cell.textLabel.text = @"修改會員資料";
				}
				else {
						
					cell.textLabel.text = @"忘記密碼";
				}
					
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
		NSString *tmpStr, *finalStr;
		
		NSDate *today = [NSDate date];
		NSDate *expiredDate = user.expireDate;
		
		NSTimeInterval theTimeInterval = [expiredDate timeIntervalSinceDate:today];

		if (theTimeInterval>0)
		{
			// Get the system calendar
			NSCalendar *sysCalendar = [NSCalendar currentCalendar];
			
			// Get conversion to months, days, hours, minutes
			unsigned int unitFlags = NSDayCalendarUnit;
			
			NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:today  toDate:expiredDate  options:0];
			
			NSLog(@"Conversion: %dmin %dhours %ddays %dmoths",[conversionInfo minute], [conversionInfo hour], [conversionInfo day], [conversionInfo month]);
			tmpStr = @"會員到期日：%@\n剩餘天數 %d 天";
			finalStr = [NSString stringWithFormat:tmpStr, [user getExpireDateByString], [conversionInfo day]+2];
		}
		else 
		{
			tmpStr = @"會員到期日：%@\n已過期";
			finalStr = [NSString stringWithFormat:tmpStr, [user getExpireDateByString]];
		}
		
		return finalStr;
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
				if (self.user)
				{
					[self addPayButtonClick];
				}
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView reloadData];
	NSLog(@" ===================================== reload called");
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
    [super dealloc];
}

@end
