//
//  User.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize username,password,authkey,expireDate, invalidDate, fontSize;

- (id)init {
	if (self = [super init]) {
		dateformatterForInput = [[NSDateFormatter alloc] init];
		[dateformatterForInput setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
		dateformatterForOutput = [[NSDateFormatter alloc] init];
		[dateformatterForOutput setDateFormat:@"yyyy/MM/dd"];
		fontSize = 22.0F;
		
		NSLog(@"font size %f", fontSize);
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
	return [dateformatterForOutput stringFromDate:expireDate];
}

-(void)setInvalidDateByString:(NSString *)dateString
{
	NSDate *date = [dateformatterForInput dateFromString:dateString]; 
	self.invalidDate = date;
}

-(NSString*)getInvalidDateByString
{
	return [dateformatterForOutput stringFromDate:invalidDate];
}

- (void)dealloc {
    [username release];
	[password release];
	[authkey release];
	[expireDate release];
	[invalidDate release];
	[dateformatterForInput release];
	[dateformatterForOutput release];

	[super dealloc];
}
@end