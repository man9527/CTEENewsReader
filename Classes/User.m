//
//  User.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize username,password,authkey,expireDate;

- (id)init {
	if (self = [super init]) {
		dateformatterForInput = [[NSDateFormatter alloc] init];
		[dateformatterForInput setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
		dateformatterForOutput = [[NSDateFormatter alloc] init];
		[dateformatterForOutput setDateFormat:@"yyyy/MM/dd"];
	}

	return self;
}	

- (bool)isPaid
{
	NSLog(@"user auth key %@", authkey);
	if (authkey==nil || [authkey isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
		return false;
	}
	else {
		NSDate *now = [NSDate date];
		switch ([self.expireDate compare:now]) {
			case NSOrderedAscending:
			case NSOrderedSame:
				return false;
				break;				
			default:
				return true;
				break;
		}
	}
}

-(void)setExpireDateByString:(NSString *)dateString
{
	NSDate *date = [dateformatterForInput dateFromString:dateString]; 
	self.expireDate = date;
}

-(NSString*)getExpireDateByString
{
	// NSDateFormatter *dateFormatTmp = [[[NSDateFormatter alloc] init] autorelease];
	// [dateFormatTmp setDateFormat:@"yyyy/MM/dd"];
	return [dateformatterForOutput stringFromDate:expireDate];
}

- (void)dealloc {
    [username release];
	[password release];
	[authkey release];
	[expireDate release];
	[dateformatterForInput release];
	[dateformatterForOutput release];

	[super dealloc];
}
@end