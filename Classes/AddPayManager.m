//
//  AddPayManager.m
//  IBENewsReader
//
//  Created by William Chu on 2010/12/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddPayManager.h"
#import "URLManager.h"
#import "UserService.h"
#import "User.h"
#import "JSON.h"
#import "URLConnectionManager.h"

@implementation AddPayManager

@synthesize delegate, addPayConnection, addPayResultData, user;

-(void)addPay:(User*) u withPayCode:(NSString*)paycode
{
	self.user = u;
	// NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[URLManager getAddPayURLForUser:self.user withPayCode:paycode]]];
	// addPayConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
	self.addPayConnection = [URLConnectionManager getURLConnectionWithURL:[URLManager getAddPayURLForUser:self.user withPayCode:paycode] delegate:self];
}


// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.addPayResultData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.addPayResultData appendData:data]; 
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (delegate!=nil)
		[delegate didAddPayResult:false andReason:@"連線錯誤" For:self.user];
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// NSString* json_string = [[NSString alloc] initWithData:self.addPayResultData encoding:NSUTF8StringEncoding];
	
	// used for temporary
	NSString* json_string = @"{\"status\":\"0\",\"errdesc\":\"aaa\",\"newenddate\":\"2011/12/31 22:00:00\"}";
	
	NSDictionary *jsonObj = [json_string JSONValue];
	self.addPayConnection = nil;

	NSString* result = [jsonObj objectForKey:@"status"];
	NSString* errdesc = [jsonObj objectForKey:@"errdesc"];
	NSString* enddate = [jsonObj objectForKey:@"newenddate"];
	
	if([result isEqualToString: @"0"]) {
		[self.user setExpireDateByString:enddate];
		[UserService setCurrentLogonUser:self.user];
	}
	
	if (delegate!=nil)
	{
		[delegate didAddPayResult:[result intValue] andReason:errdesc For:self.user];
	}
	
	[json_string release]; 
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void) dealloc
{
	[addPayConnection release];
	[addPayResultData release];
	[user release];
	
	[super dealloc];
}

@end
