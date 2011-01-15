//
//  UIAddPayFailDelegate.m
//  IBENewsReader
//
//  Created by William Chu on 2010/12/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIAddPayFailDelegate.h"
#import "IBENewsReaderAppDelegate.h"

@implementation UIAddPayFailDelegate
@synthesize param;

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAddPayForm" object:nil]; // userInfo:param];

	// IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	//[appDelegate showAddPayForm:param];
}


- (void)dealloc {
	// [param release];
    [super dealloc];
}

@end
