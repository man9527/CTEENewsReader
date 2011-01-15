//
//  UserPassRepository.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserPassRepository.h"
#import "Constants.h"

@implementation UserPassRepository

+(User*)getUser
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *username = [prefs stringForKey:UserNameKey];
	NSString *password = [prefs stringForKey:PasswordKey];
	NSString *authkey = [prefs stringForKey:AuthKey];
	NSDate *expiredDate = [prefs objectForKey:ExpiredDateKey];
	
	if (username!=NULL && password!=NULL)
	{
		User *u = [[User alloc]init];
		u.username = username;
		u.password = password;
		u.authkey = authkey;
		u.expireDate = expiredDate;
		[u autorelease];

		return u;
	}
	else {
		return NULL;
	}
}

+(void)setUser:(User *)u
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:u.username forKey:UserNameKey];
	[prefs setObject:u.password forKey:PasswordKey];
	[prefs setObject:u.authkey forKey:AuthKey];
	[prefs setObject:u.expireDate forKey:ExpiredDateKey];
	
	[prefs synchronize];
}

+(void)deleteUser:(User *)u
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs removeObjectForKey:UserNameKey];
	[prefs removeObjectForKey:PasswordKey];
	[prefs removeObjectForKey:AuthKey];
	[prefs removeObjectForKey:ExpiredDateKey];
	
	[prefs synchronize];
}

@end
