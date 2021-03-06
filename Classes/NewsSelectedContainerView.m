    //
//  NewsSelectedContainerView.m
//  IBENewsReader
//
//  Created by William Chu on 2011/1/5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsSelectedContainerView.h"

@implementation NewsSelectedContainerView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[super awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.navigationController.delegate = self;
}

- (void)setupStaticKeyString
{
	NewsTypeName = @"SelectedNews";
	titleTemplate = @"精選新聞(%i/%i)";
	selfTitle = @"精選新聞";
	requestKey = @"";
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController isKindOfClass:[NewsSelectedContainerView class]])
	{
		[self loadNewsData:NO];
		[self.navigationController setToolbarHidden:YES animated:NO];
	}
}


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
