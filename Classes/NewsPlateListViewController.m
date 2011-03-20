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
@synthesize entries, newsData, expiredCachedData, doAutoReload, dateformatter, appListData, appListFeedConnection, plateName, cachekey, footer, listTableView, cachedControllers;

#pragma mark -
#pragma mark View lifecycle

-(void)awakeFromNib {
	self.dateformatter = [[NSDateFormatter alloc] init]; 
	[self.dateformatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];	

	self.entries = [[NSMutableArray alloc] init];
	self.plateName = [[NSMutableArray alloc] init];
	self.cachedControllers = [NSMutableDictionary dictionary];

	self.navigationController.toolbar.tintColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1];
	self.navigationController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	NewsTypeName = @"HeadNewsByPlate";
	self.cachekey = NewsTypeName;
	doAutoReload = YES;

	self.footer = [[NewsListFooterViewController alloc] initWithNibName:@"NewsListFooterViewController" bundle:nil];
	self.footer.delegate = self;

	self.footer.view.frame = CGRectMake(0, self.listTableView.frame.origin.y+self.listTableView.frame.size.height, footer.view.frame.size.width, footer.view.frame.size.height);
	[self.view addSubview:footer.view];
}

- (void)loadNewsData:(bool)forceReload
{
	// 1. load data from cache
	//if (expiredCachedData==nil)
	//{
		NSDictionary *cachedData = [CacheManager getCachedData:cachekey];
		[cachedData retain];
		self.expiredCachedData = cachedData;
		[cachedData release];
	//}
	  
	// 2. if no cached data or force reload
	if ( (self.expiredCachedData == nil && doAutoReload) || forceReload)
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
		NSString *newExpiredDateStr = [self.expiredCachedData objectForKey:@"invalidtime"];
		NSDate *newsExpiredDate = [dateformatter dateFromString:newExpiredDateStr]; 
		NSDate *now = [NSDate date];
		
		switch ([newsExpiredDate compare:now]) {
			case NSOrderedAscending:
			case NSOrderedSame:
				// need to expired
				if (doAutoReload)
				{
					[self loadNewsData:YES];
					break;				
				}
			default:
				// use cached data
				self.newsData = self.expiredCachedData;
				[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];
				break;
		}
	}
}

- (void)reloadAD
{
	// do nothing
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

		[self.listTableView reloadData];
		[self setFooterLabel];
	}
}

- (NSString*)getNewsRequestURL
{
	User *user = [UserService currentLogonUser];
	NSString *url = [URLManager getHeadNewsURLForUser:user];
	return url;
}

- (void)setFooterLabel
{
	NSMutableString *updateTimeStr = [[NSMutableString alloc] initWithString:@"Updated："];
	[updateTimeStr appendString:[self.newsData objectForKey:@"updatetime"]];
	[self.footer.dateLabel setTitle:updateTimeStr forState:UIControlStateNormal];
	[updateTimeStr release];
}

#pragma mark -
#pragma mark Table view data source

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
			cell.textLabel.font=[UIFont boldSystemFontOfSize:20.0];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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
			cell.textLabel.font=[UIFont boldSystemFontOfSize:20.0];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row>0)
	{
		IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
		
		if ( [appDelegate validateForPaidUser] ) {
			NewsPlateContainerViewController *container = [self.cachedControllers objectForKey:[self.entries objectAtIndex:indexPath.row-1]];
			
			if (container==nil) {
				container = [[NewsPlateContainerViewController alloc] initWithNibName:@"NewsPlateContainerViewController" bundle:nil];
				container.requestKey=[self.entries objectAtIndex:indexPath.row-1];
				NSString *keyText = [self.plateName objectAtIndex:indexPath.row-1];
				container.selfTitle = keyText;
				container.titleTemplate = [NSString stringWithFormat:@"%@ (%@/%@)", keyText, @"%i", @"%i"];
				container.doAutoReload = doAutoReload;
				[self.cachedControllers setObject:container forKey:[self.entries objectAtIndex:indexPath.row-1]];
				[container autorelease];
			}
			else {
				[container viewWillAppear:NO];
			}

			[self.navigationController pushViewController:container animated:YES];
		}
	}
	else 
	{
		NewsPlateHeadContainerViewController *container = [self.cachedControllers objectForKey:@"headplate"];
		
		if (container==nil) 
		{
			container = [[NewsPlateHeadContainerViewController alloc] initWithNibName:@"NewsPlateContainerViewController" bundle:nil];
			NSString *keyText = @"各版頭條";
			container.selfTitle = keyText;
			container.titleTemplate = [NSString stringWithFormat:@"%@ (%@/%@)", keyText, @"%i", @"%i"];
			container.doAutoReload = doAutoReload;
			[self.cachedControllers setObject:container forKey:@"headplate"];
			[container autorelease];
		}
		else {
			[container viewWillAppear:NO];
		}
		
		[self.navigationController pushViewController:container animated:YES];
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
    
    self.appListFeedConnection = nil;   // release our connection

	doAutoReload = NO;

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"此功能需要網路連線" message:nil  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
	[alert show];
	[alert release];		
	
	[self setNewsData:self.expiredCachedData];
	[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.appListFeedConnection = nil;   // release our connection
	doAutoReload = YES;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showLoading:FALSE withText:nil];
    
	NSString* json_string = [[NSString alloc] initWithData:appListData encoding:NSUTF8StringEncoding];
	//NSString* json_string =
	//@"{\"status\":\"0\",	   \"errdesc\":null,	   \"updatetime\":\"2012/12/31 08:00:00\",	   \"invalidtime\":\"2010/12/31 22:00:00\",	   \"news\":[{\"clipid\":662999,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A1 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\",\"content\":\"content打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲\", \"thumb\":\"http://www.williamlong.info/upload/2427_3.jpg\", \"img\":\"http://blog.lib.umn.edu/rade0117/architecture/baby.jpg\"}, 	{\"clipid\":663000,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A2 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 2\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\", \"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\",\"thumb\":\"http://designexcite.com/images/s-logo.png\",\"img\":\"http://www.thefrogandtheprincess.com/Images/baby-aspen-welcome-home-baby-blue-set-2.jpg\",\"related\":[{\"clipid\":663001,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A2 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 3\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\", \"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\",\"img\":\"http://designexcite.com/images/s-logo.png\"},{\"clipid\":663001,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A2 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 4\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\", \"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\",\"img\":\"http://designexcite.com/images/s-logo.png\"}] }, {\"clipid\":662999,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A1 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 5\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\",\"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\", \"thumb\":\"http://www.williamlong.info/upload/2427_3.jpg\", \"img\":\"http://blog.lib.umn.edu/rade0117/architecture/baby.jpg\"}, {\"clipid\":662999,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A1 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 6\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\",\"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\", \"thumb\":\"http://www.williamlong.info/upload/2427_3.jpg\", \"img\":\"http://blog.lib.umn.edu/rade0117/architecture/baby.jpg\"}, {\"clipid\":662999,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A1 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 7\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\",\"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\", \"thumb\":\"http://www.williamlong.info/upload/2427_3.jpg\", \"img\":\"http://blog.lib.umn.edu/rade0117/architecture/baby.jpg\"}]}";

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

	if([status isEqualToString: @"0"]) 
	{ 
		[self setNewsData:data];
		[CacheManager cacheData:data withType:cachekey];
	}
	else {
		if([status isEqualToString: @"3"]) { 
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoginForm" object:nil userInfo:nil];
		}
		else 
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"讀取資料錯誤" message:[data objectForKey:@"errdesc"]  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}

		[self setNewsData:self.expiredCachedData];
	}
	
	[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];
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
	
	/*if ([viewController isKindOfClass:[NewsPlateListViewController class]])
	{
		[self loadNewsData:NO];
	}
	
	else */if ([viewController isKindOfClass:[NewsPlateContainerViewController class]])
	{
		[self.navigationController setToolbarHidden:YES animated:NO];
		// [(NewsPlateContainerViewController*)viewController loadNewsData:NO];
	}
	else if ([viewController isKindOfClass:[NewsPlateHeadContainerViewController class]])
	{
		[self.navigationController setToolbarHidden:YES animated:NO];
		//[(NewsPlateHeadContainerViewController*)viewController loadNewsData:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSLog(@"======================= called from NewsPlateListViewController viewWillAppear");	
	[self loadNewsData:NO];
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
	[listTableView release];
	[cachedControllers release];
    [super dealloc];
}


@end

