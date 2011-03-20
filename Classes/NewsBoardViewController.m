//
//  NewsBoardViewController.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewsBoardViewController.h"
#import "CacheManager.h"
#import "UserIndustrySetting.h"
#import "User.h"
#import "UserService.h"

@implementation NewsBoardViewController
@synthesize aboutText;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self performSelector:@selector(updateUI) withObject:nil afterDelay:0.0];
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

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self performSelector:@selector(updateUI) withObject:nil afterDelay:0.0];
}

-(void)updateUI
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
	
	NSString *imagePath = [[NSBundle mainBundle] resourcePath];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	int fontSize = 22;
	User *u = [UserService currentLogonUser];
	if (u!=nil)
	{
		fontSize = (int)u.fontSize;
	}
	
	
	NSString *htmlString = [[NSString alloc] initWithData:[readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	NSString *htmlString2 = [NSString stringWithFormat:htmlString, fontSize];// [htmlString stringByReplacingOccurrencesOfString:@"[fontSize]" withString:[NSString stringWithFormat:@"%d",fontSize]];
	self.aboutText.delegate = self;
	[self.aboutText loadHTMLString:htmlString2 baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",imagePath]]];
	[htmlString release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[aboutText release];
    [super dealloc];
}


@end
