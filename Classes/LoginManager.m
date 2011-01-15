//
//  LoginManager.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginManager.h"
#import "JSON.h"
#import "URLManager.h"
#import "UserService.h"
#import "URLConnectionManager.h"

@implementation LoginManager
@synthesize delegate, loginConnection, loginResultData, user;

-(void)login:(User*) u
{
	self.user = u;
	loginConnection = [URLConnectionManager getURLConnectionWithURL:[URLManager getLoginURLForUser:self.user] delegate:self];
}

-(void)logout:(User*) u
{
	[UserService logoutCurrentLogonUser:u];
}


// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.loginResultData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.loginResultData appendData:data]; 
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	loginConnection = nil;

	if (delegate!=nil)
	{
		[delegate didLoginResult:false andReason:@"連線錯誤" For:self.user];
	}
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString* json_string = [[NSString alloc] initWithData:self.loginResultData encoding:NSUTF8StringEncoding];

	// used for temporary
	// json_string = @"{\"status\":\"0\",\"errdesc\":\"aaa\",\"authkey\":\"aaa\",\"enddate\":\"2010/12/31 12:00:00\"}";

	NSDictionary *jsonObj = [json_string JSONValue];
	loginConnection = nil;

	NSString* result = [jsonObj objectForKey:@"status"];
	NSString* errdesc = [jsonObj objectForKey:@"errdesc"];

	bool status;
	
	if([result isEqualToString: @"0"] || [result isEqualToString: @"1"]) {
		NSLog(@"authkey: %@",self.user.authkey);

		status = true;
		self.user.authkey = [jsonObj objectForKey:@"authkey"];
		[self.user setExpireDateByString:[jsonObj objectForKey:@"enddate"]];
		[UserService setCurrentLogonUser:self.user];
	}
	else 
	{
		status = false;
		[UserService logoutCurrentLogonUser:self.user];
	}

	if (delegate!=nil)
		[delegate didLoginResult:status andReason:errdesc For:self.user];

	[json_string release]; 

	// [jsonObj release];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	}
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


-(void) dealloc
{
	[loginConnection release];
	[loginResultData release];
	[user release];
		
	[super dealloc];
}
@end
