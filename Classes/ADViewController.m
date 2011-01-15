//
//  ADViewController.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ADViewController.h"


@implementation ADViewController
@synthesize adView;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil adpath:(NSString*)path {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		adpath = path;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	NSString *path = [[NSBundle mainBundle] pathForResource:adpath ofType:@"html"];
	NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
	
	NSString *htmlString = [[NSString alloc] initWithData:[readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	
	[self.adView loadHTMLString:htmlString baseURL:nil];
	[htmlString release];
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
