//
//  URLConnectionManager.m
//  IBENewsReader
//
//  Created by William Chu on 2011/1/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "URLConnectionManager.h"


@implementation URLConnectionManager

+ (NSURLConnection*) getURLConnectionWithURL:(NSString*) urlString delegate:(id)delegate
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
	NSURLConnection *conn = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:delegate] autorelease];
	return conn;
}

@end
