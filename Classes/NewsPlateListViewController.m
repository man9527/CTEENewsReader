//
//  NewsPlateListViewController.m
//  IBENewsReader
//
//  Created by William Chu on 2011/1/6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsPlateListViewController.h"
#import "CacheManager.h"
#import "IBENewsReaderAppDelegate.h"
#import "UserService.h"
#import "URLManager.h"
#import "JSON.h"
#import "URLConnectionManager.h"
#import "NewsPlateContainerViewController.h"
#import "NewsPlateHeadContainerViewController.h"
// #define kCustomRowHeight    95.0
#define kCustomRowCount     4

@implementation NewsPlateListViewController
@synthesize entries, newsData, expiredCachedData, dateformatter, appListData, appListFeedConnection, plateName, cachekey;

#pragma mark -
#pragma mark View lifecycle

-(void)awakeFromNib {
	self.dateformatter = [[NSDateFormatter alloc] init]; 
	[self.dateformatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];	

	self.entries = [[NSMutableArray alloc] init];
	self.plateName = [[NSMutableArray alloc] init];
	
	self.navigationController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NewsTypeName = @"HeadNewsByPlate";
	self.cachekey = NewsTypeName;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadNewsData:(bool)forceReload
{
	if (expiredCachedData != nil && [expiredCachedData retainCount]>0)
	{
		[expiredCachedData release];
		expiredCachedData = nil;
	}
	
	// 1. load data from cache
	NSDictionary *cachedData = [CacheManager getCachedData:cachekey];
	[cachedData retain];
	self.expiredCachedData = cachedData;
	
	// 2. if no cached data or force reload
	if (cachedData==nil || forceReload)
	{
		IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate showLoading:TRUE withText:@"資料讀取中"];
				
		self.appListFeedConnection = [URLConnectionManager getURLConnectionWithURL:[self getNewsRequestURL] delegate:self];
		
		if (self.appListFeedConnection==nil)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"無法開啟網路連接" message:nil  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];		
		}
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;		
	}
	else {
		NSString *newExpiredDateStr = [cachedData objectForKey:@"invalidtime"];
		NSDate *newsExpiredDate = [dateformatter dateFromString:newExpiredDateStr]; 
		NSDate *now = [NSDate date];
		
		switch ([newsExpiredDate compare:now]) {
			case NSOrderedAscending:
			case NSOrderedSame:
				// need to expired
				NSLog(@"in load news data call second time");
				[self loadNewsData:YES];
				break;				
			default:
				// use cached data
				// [self setNewsData:cachedData];
				newsData = cachedData;
				[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];
				break;
		}
		//[newExpiredDateStr release];
	}
	
	[cachedData release];
}

- (void)handleLoadedApps // :(NSDictionary *)loadedNews
{
	if (self.newsData!=nil && [self.newsData count]>0)
	{
		NSArray *news = [self.newsData objectForKey:@"news"];

		if (self.entries)
		{
			[self.entries release];
			self.entries = [[NSMutableArray alloc] init];
		}
		
		if (self.plateName)
		{
			[self.plateName release];
			self.plateName = [[NSMutableArray alloc] init];
		}	

		for (NSDictionary *anews in news) 
		{
			[entries addObject:[anews objectForKey:@"plate"]];
			[plateName addObject:[anews objectForKey:@"platename"]];
		}

		[self.tableView reloadData];
	}
}

- (NSString*)getNewsRequestURL
{
	User *user = [UserService currentLogonUser];
	NSString *url = [URLManager getHeadNewsURLForUser:user];
	NSLog(@"head news url: %@", url);
	return url;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int count = [entries count];

	// ff there's no data yet, return enough rows to fill the screen
    if (count == 0)
	{
        return 1;
    }
    return count+1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *PlateNewsIdentifier = @"PlateNewsCell";
	static NSString *HeadNewsIdentifier = @"HeadNewsCell";
	
	if (indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeadNewsIdentifier];

        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:HeadNewsIdentifier] autorelease];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
		
		cell.textLabel.text = @"各版頭條";
		
		return cell;
    }
	else 
	{
		int nodeCount = [self.entries count];

		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlateNewsIdentifier];

		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:PlateNewsIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		// Leave cells empty if there's no data yet
		if (nodeCount > 0)
		{
			// Set up the cell...
			cell.textLabel.text = [self.plateName objectAtIndex:indexPath.row-1];
		}
		
		return cell;	
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row>0)
	{
		IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
		
		if ( [appDelegate validateForPaidUser] ) {
			NewsPlateContainerViewController *container = [[NewsPlateContainerViewController alloc] initWithNibName:@"NewsPlateContainerViewController" bundle:nil];
			container.requestKey=[self.entries objectAtIndex:indexPath.row-1];
			NSString *keyText = [self.plateName objectAtIndex:indexPath.row-1];
			container.selfTitle = keyText;
			container.titleTemplate = [NSString stringWithFormat:@"%@ (%@/%@)", keyText, @"%i", @"%i"];
			[self.navigationController pushViewController:container animated:YES];
			[container release];
		}
	}
	else {
		NewsPlateHeadContainerViewController *container = [[NewsPlateHeadContainerViewController alloc] initWithNibName:@"NewsPlateContainerViewController" bundle:nil];
		NSString *keyText = @"各版頭條";
		container.selfTitle = keyText;
		container.titleTemplate = [NSString stringWithFormat:@"%@ (%@/%@)", keyText, @"%i", @"%i"];
		// container.delegate = self;
		[self.navigationController pushViewController:container animated:YES];
		[container release];
	}
}

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.appListData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [appListData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showLoading:FALSE withText:nil];
	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"連線錯誤" message:nil  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
	[alert show];
	[alert release];		
    
    self.appListFeedConnection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.appListFeedConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showLoading:FALSE withText:nil];
    
	NSString* json_string = [[NSString alloc] initWithData:appListData encoding:NSUTF8StringEncoding];
	
	// NSLog(@"%@",json_string);
	
	NSDictionary *jsonObj = [json_string JSONValue];
	[jsonObj retain];
	[self handleNewsData:jsonObj];
    self.appListData = nil;
	
	[jsonObj release];
	[json_string release];
}

- (void)handleNewsData:(NSDictionary*)data
{
	NSString *status = [data objectForKey:@"status"];

	if([status isEqualToString: @"0"]) { 

		if (data!=nil)
		{
			[self setNewsData:data];
		}
		else if (self.expiredCachedData!=nil)
		{
			[self setNewsData:self.expiredCachedData];
		}
		else {
			[self setNewsData:nil];
		}
		
		[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];
		[CacheManager cacheData:data withType:cachekey];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"讀取新聞錯誤" message:[data objectForKey:@"errdesc"]  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];		
	}
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];
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


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController isKindOfClass:[NewsPlateListViewController class]])
	{
		[self loadNewsData:NO];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[entries release];
	[newsData release];
	[expiredCachedData release];
	[dateformatter release];
	[appListData release];
	[appListFeedConnection release];
	[plateName release];
	[cachekey release];
    [super dealloc];
}


@end

