//
//  UserService.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserService.h"
#import "User.h"
#import "UserPassRepository.h"

@implementation UserService
static User *currentLogonUser;
+(User*)currentLogonUser {return currentLogonUser;}
+(void)setCurrentLogonUser:(User *)u 
{
	NSLog(@"set current logon user");
	
	if (currentLogonUser)
	{
		[currentLogonUser release];
	}

	currentLogonUser = u;
	[currentLogonUser retain];

	[self saveUserLocal:u];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationEvent" object:nil];
	
}

+(void)logoutCurrentLogonUser:(User*)u
{
	NSLog(@"delete current logon user");

	[self deleteUserLocal:u];

	[currentLogonUser release];
	currentLogonUser = nil;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationEvent" object:nil];
}

+(void)saveUserLocal:(User*)u
{
	[UserPassRepository setUser:u];	
}

+(User*)getUserLocal
{
	return [UserPassRepository getUser];
}

+(void)deleteUserLocal:(User*)u
{
	[UserPassRepository deleteUser:u];
}

+(void)loadCacheUserAsLogonUser
{
	[self setCurrentLogonUser:[self getUserLocal]];
}
@end
