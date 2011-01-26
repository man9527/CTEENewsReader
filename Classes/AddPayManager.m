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

#define kAddPayStatusSuccess		0
#define kAddPayStatusLoginFail		1
#define kAddPayStatusFail			4

@implementation AddPayManager

@synthesize delegate, addPayConnection, addPayResultData, user;

-(void)addPay:(User*) u withPayCode:(NSString*)paycode
{
	self.user = u;
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
		[delegate didAddPayResult:kAddPayStatusFail andReason:@"此功能需要網路連線" For:self.user];
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString* json_string = [[NSString alloc] initWithData:self.addPayResultData encoding:NSUTF8StringEncoding];
	NSDictionary *jsonObj = [json_string JSONValue];
	self.addPayConnection = nil;
	NSLog(@"add pay %@", json_string);
	NSString* result =nil;
	NSString* errdesc =nil;
	NSString* enddate=nil;

	if (jsonObj==nil)
	{
		result=[NSString stringWithFormat:@"%d",kAddPayStatusFail];
	}
	else 
	{
		result = [jsonObj objectForKey:@"status"];
		errdesc = [jsonObj objectForKey:@"errdesc"];
		enddate = [jsonObj objectForKey:@"newenddate"];
	}

		
	if([result isEqualToString:[NSString stringWithFormat:@"%d",kAddPayStatusSuccess]]) {
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
