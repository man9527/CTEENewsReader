//
//  ADViewController.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ADViewController.h"

static NSString *const adURL=@"https://d9.ctee.com.tw/m/adscode.aspx?zone=%@&sub=%@";
// static NSString *adFilePath=@"advertisement";

@implementation ADViewController
@synthesize adView, delegate;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil zoneid:(NSString*)zoneidparam sub:(NSString*)subparam {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	zoneid=zoneidparam;
	sub=subparam;
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadADContent];
	//[self performSelectorOnMainThread:@selector(loadADContent) withObject:nil waitUntilDone:NO];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	else {
		return YES;
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"AD load error");
	[delegate didLoadAD:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"AD load ok");
	[delegate didLoadAD:YES];
}

- (void)loadADContent
{
	/*
	NSString *path = [[NSBundle mainBundle] pathForResource:@"advertisement" ofType:@"html"];
	NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
	
	NSString *htmlString = [[NSString alloc] initWithData:[readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	self.adView.delegate = self;
	[self.adView loadHTMLString:[NSString stringWithFormat:htmlString, [NSString stringWithFormat:adURL, zoneid, sub]] baseURL:nil];
	[htmlString release];	
	 */
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:adURL, zoneid, sub]];
	[self.adView loadRequest:[NSURLRequest requestWithURL:url] ];
}

- (void)reload
{
	//[self performSelectorOnMainThread:@selector(loadADContent) withObject:nil waitUntilDone:NO];
	[self loadADContent];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[adView release];
    [super dealloc];
}


@end
