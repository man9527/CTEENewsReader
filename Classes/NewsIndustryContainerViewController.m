//
//  NewsIndustryContainerViewController.m
//  IBENewsReader
//
//  Created by William Chu on 2011/1/5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsIndustryContainerViewController.h"
#import "UserService.h"
#import "URLManager.h"

@implementation NewsIndustryContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[super awakeFromNib];
    }
    return self;
}

- (void)setupStaticKeyString
{
	NewsTypeName = @"IndustryNews";
}

#pragma mark need to override these methods
/*
- (void)initSubViews
{
	self.adViewController = [[ADViewController alloc] initWithNibName:@"ADViewController" bundle:nil];
	
	self.newsListViewController = [[NewsListViewController alloc] initWithNibName:@"NewsListViewController" bundle:nil];
	self.newsListViewController.entries = [NSMutableArray array];
	self.newsListViewController.delegate = self;
	
	self.footer = [[NewsListFooterViewController alloc] initWithNibName:@"NewsListFooterViewController" bundle:nil];
	self.footer.delegate = self;
}

- (void)layoutSubViews
{
	int position = 0;
	int newsListViewHeight = 336;
	
	if (self.adViewController)
	{
		self.adViewController.view.frame = CGRectMake(10, 0, adViewController.view.frame.size.width, adViewController.view.frame.size.height);
		[self.view addSubview:adViewController.view];
		
		position += self.adViewController.view.frame.size.height;
		newsListViewHeight -= self.adViewController.view.frame.size.height;
	}
	
	self.newsListViewController.view.frame = CGRectMake(0, position, newsListViewController.view.frame.size.width, newsListViewHeight);
	[self.view addSubview:newsListViewController.view];
	
	position += self.newsListViewController.view.frame.size.height;
	
	self.footer.view.frame = CGRectMake(0, position, footer.view.frame.size.width, footer.view.frame.size.height);
	[self.view addSubview:footer.view];
}*/

- (NSString*)getNewsRequestURL
{
	User *user = [UserService currentLogonUser];
	NSString *url = [URLManager getNewsByPlateURLForUser:user withPlate:@"A01AA1"];
	return url;
}


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
    [super dealloc];
}


@end
