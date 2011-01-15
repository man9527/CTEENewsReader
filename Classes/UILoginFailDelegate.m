//
//  UILoginFailDelegate.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UILoginFailDelegate.h"
#import "IBENewsReaderAppDelegate.h"

@implementation UILoginFailDelegate
@synthesize param;

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex: (NSInteger)buttonIndex
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoginForm" object:nil]; // userInfo:param];
}


- (void)dealloc {
	// [param release];
    [super dealloc];
}

@end
