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
@implementation NewsBoardViewController


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
	// self.title = @"aaa";
	//UIViewController *u = [[NewsBoardViewController alloc] initWithNibName:@"NewsBoardViewController" bundle:nil];
	// [self.navigationController pushViewController:u animated:YES];
	/*
	UserIndustrySetting *uis = [UserIndustrySetting sharedUserIndustrySetting];
	
	NSArray *selected = [uis getAllSelectedIndustryId];
	NSArray *nonselected = [uis getAllNonSelectedIndustryId];

	//[uis setSelectedIndustry:[nonselected objectAtIndex:0] selected:true];
	//[uis setSelectedIndustry:[nonselected objectAtIndex:1] selected:true];
	//[uis setSelectedIndustry:[nonselected objectAtIndex:2] selected:true];

	selected = [uis getAllSelectedIndustryId];
	
	for (NSString *s in selected)
	{
		NSLog(@"selected: %@",s);
	}
	
	
	//[uis moveSelectedIndustryFrom:2 To:0];//   moveSelectedIndustryFrom:0 To:2];
	//selected = [uis getAllSelectedIndustryId];

	for (NSString *s in selected)
	{
		NSLog(@"selected: %@",s);
	}
/*
	NSArray *nonselected = [uis getAllNonSelectedIndustryId];
	
	for (NSString *s in nonselected)
	{
		NSLog(@"nonselected: %@",s);
	}
*/	
	/*
	NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"http://www.android-hk.com/wordpress/wp-content/uploads/2010/11/1_google_logo.jpg"]];
	UIImage *image = [[UIImage alloc] initWithData: data];
	 
	[CacheManager cacheImage:image withName:@"http://www.android-hk.com/wordpress/wp-content/uploads/2010/11/1_google_logo.jpg"];
	
	UIImage *img = [CacheManager getCachedImage:@"http://www.android-hk.com/wordpress/wp-content/uploads/2010/11/1_google_logo.jpg"];
	[img retain];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
	[self.view addSubview:imageView];
	
	
	NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] init];
	[plistDict setObject:@"dasdasdas" forKey:@"ddd"];

	[CacheManager cacheData:plistDict withType:@"test"];
	
	NSDictionary* plistDict2 = [CacheManager getCachedData:@"test1111"];
	
	if (plistDict2 == nil)
		NSLog(@"ccccc");
	else {
		NSLog(@"daaaa");
	}
	 */
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
    [super dealloc];
}


@end
