//
//  UIAddPayView.m
//  IBENewsReader
//
//  Created by William Chu on 2010/12/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIAddPayView.h"
#import "UserService.h"
#import "IBENewsReaderAppDelegate.h"
#import "UIAddPayFailDelegate.h"

#define kAddPayStatusSuccess		0
#define kAddPayStatusLoginFail		1
#define kAddPayStatusFail			4
#define NUMBERS	@"0123456789"

@implementation UIAddPayView
@synthesize addPayTextField, failDelegate, addPayManager;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		failDelegate =  [[UIAddPayFailDelegate alloc]init];;
		
		addPayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		addPayLabel.backgroundColor = [UIColor clearColor];
		addPayLabel.text = @"儲值碼";
		addPayLabel.textColor = [UIColor whiteColor];
		addPayLabel.font = [UIFont systemFontOfSize:20];
		
		addPayTextField = [[UITextField alloc] initWithFrame:CGRectZero]; 
		addPayTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		addPayTextField.keyboardType = UIKeyboardTypeNumberPad;
		addPayTextField.delegate = self;
		[addPayTextField setBorderStyle:UITextBorderStyleRoundedRect];
		
		//[self addSubview:addPayLabel];
		[self addSubview:addPayTextField];
		
	}
	return self;
}

- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles, ... 
{	
	if ( self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles,nil] )
	{
		self.delegate = self;
		self.tag = 3000;
	}
	return self;
}

- (void)setFrame:(CGRect)rect {
	[super setFrame:CGRectMake(0, 0, rect.size.width, 150)];
	self.center = CGPointMake(160, 200);
}

- (void)layoutSubviews {
	[self setFrame:self.frame];
	
	CGFloat buttonTop = 0.0;
	
	for (UIView *view in self.subviews) {
		if ([[[view class] description] isEqualToString:@"UIThreePartButton"]) {
			view.frame = CGRectMake(view.frame.origin.x, self.bounds.size.height - view.frame.size.height - 15, view.frame.size.width, view.frame.size.height);
			buttonTop = view.frame.origin.y;
		}
	}
	
	buttonTop -= 35; // buttonTop -= 23;
	
	addPayLabel.frame = CGRectMake(12, buttonTop, self.frame.size.width - 52, 30);
	addPayTextField.frame = CGRectMake(52, addPayLabel.frame.origin.y, 180, addPayLabel.frame.size.height);
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (alertView.tag==3000)
	{
		if (buttonIndex==1)
		{
			[addPayTextField resignFirstResponder];
			
			if ([self checkInput])
			{
				[appDelegate showLoading:TRUE withText:@"儲值中..."];
				
				User *user = [UserService currentLogonUser];
				
				addPayManager.delegate = self;
				
				[addPayManager addPay:user withPayCode:addPayTextField.text];
			}
		}
	}
}


- (void)didAddPayResult:(int)status andReason:(NSString*)reason For:(User*) u
{
	NSLog(@"in add pay result");
	
	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showLoading:FALSE withText:nil];
	
	NSString *title;
	bool showAgain;
	if (status==kAddPayStatusLoginFail)
	{
		title = @"登入失敗";
		showAgain = YES;
	}
	else if (status==kAddPayStatusFail)
	{
		title = @"儲值失敗";
		showAgain = YES;
	}
	else {
		title = @"儲值成功";
		showAgain = NO;
		reason=[NSString stringWithFormat:@"到期日：%@", [u getExpireDateByString]];
	}
	
	[self showResultDialogWithTitle:title message:reason showAgain:showAgain];
}

- (bool)checkInput
{
	NSString *addpayCode = addPayTextField.text;
	
	NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString *filtered = [[addpayCode componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
	
	if (addpayCode==nil || [addpayCode isEqual:@""])
	{
		[self showResultDialogWithTitle:@"儲值失敗" message:@"請輸入儲值碼" showAgain:YES];
		
		return FALSE;
	}
	else if (addpayCode.length!=8 || ![addpayCode isEqualToString:filtered]) {
		[self showResultDialogWithTitle:@"儲值失敗" message:@"儲值碼數字長度錯誤，請重新輸入。" showAgain:YES];
		
		return FALSE;
	}

	return TRUE;
}

-(void)showResultDialogWithTitle:(NSString*)title message:(NSString*)message showAgain:(bool)show
{
	UIAddPayFailDelegate *fail;
	
	if (show){
		fail = failDelegate;
	}
	else {
		fail = nil;
	}

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message  delegate:fail  cancelButtonTitle:nil otherButtonTitles:@"確定", nil];
	[alert show];
	[alert release];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];
	
	if (textField.text.length<=7 || ![nf numberFromString:string])
		return TRUE;
	else {
		return FALSE;
	}
	
}

-(void) dealloc
{
	[addPayTextField release];
	[addPayLabel release];
	[addPayManager release];
	[failDelegate release];
	
	[super dealloc];
}

@end
