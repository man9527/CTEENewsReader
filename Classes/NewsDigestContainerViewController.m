//
//  NewsDigestContainerViewController.m
//  IBENewsReader
//
//  Created by William Chu on 2010/12/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewsDigestContainerViewController.h"
#import "NewsListFooterViewController.h"
#import "NewsDetailViewController.h"
#import "CacheManager.h"
#import "JSON.h"
#import "IBENewsReaderAppDelegate.h"
#import "UserService.h"
#import "URLManager.h"
#import "URLConnectionManager.h"
// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>

#define kAnimationSpeed		0.3
#define kDefaultNewsListHeight 338.0
#define kDefaultADHeight 48.0

@implementation NewsDigestContainerViewController
@synthesize adViewController, appListFeedConnection, appListData,newsListViewController, footer;
@synthesize dateformatter, newsData, expiredCachedData, requestKey, selfTitle, titleTemplate;
@synthesize dataCacheKey, doAutoReload;

- (void)awakeFromNib {
	doAutoReload = YES;
	[self setupStaticKeyString];
	[self initSubViews];
	
	dateformatter = [[NSDateFormatter alloc] init]; 
	[self.dateformatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];	
	
	self.navigationController.toolbar.tintColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1];
}

- (void)viewDidLoad {

    [super viewDidLoad];
	
	self.dataCacheKey = [NewsTypeName stringByAppendingString:requestKey];
	self.navigationItem.title = selfTitle; // [NSString stringWithFormat:selfTitle, [dateStr substringToIndex:10]];

	[self layoutSubViews];
}  

#pragma mark need to override these methods
- (void)initSubViews
{
	self.adViewController = [[ADViewController alloc] initWithNibName:@"ADViewController" bundle:nil zoneid:@"1" sub:@""];
	self.adViewController.delegate = self;

	self.newsListViewController = [[NewsListViewController alloc] initWithNibName:@"NewsListViewController" bundle:nil];
	self.newsListViewController.entries = [NSMutableArray array];
	self.newsListViewController.delegate = self;

	self.footer = [[NewsListFooterViewController alloc] initWithNibName:@"NewsListFooterViewController" bundle:nil];
	self.footer.delegate = self;
}

- (void)layoutSubViews
{
	int position = 0;
	int newsListViewHeight = kDefaultNewsListHeight;
	
	if (self.adViewController)
	{
		self.adViewController.view.frame = CGRectMake(0, 0, adViewController.view.frame.size.width, adViewController.view.frame.size.height);
		[self.view addSubview:adViewController.view];

		position += self.adViewController.view.frame.size.height;
		newsListViewHeight -= self.adViewController.view.frame.size.height;
	}

	self.newsListViewController.view.frame = CGRectMake(0, position, newsListViewController.view.frame.size.width, newsListViewHeight);
	[self.view addSubview:newsListViewController.view];
	
	position += self.newsListViewController.view.frame.size.height;

	self.footer.view.frame = CGRectMake(0, position, footer.view.frame.size.width, footer.view.frame.size.height);
	[self.view addSubview:footer.view];
}

- (NSString*)getNewsRequestURL
{
	User *user = [UserService currentLogonUser];
	NSString *url = [URLManager getSelectNewsURLForUser:user];
	return url;
}

- (void)setupStaticKeyString
{
	NewsTypeName = @"SelectedNews";
	//titleTemplate = @"精選(%i/%i)";
	//selfTitle = @"精選新聞";
}

- (void)loadNewsData:(bool)forceReload
{
	// 1. load data from cache
	NSDictionary *cachedData = [CacheManager getCachedData:dataCacheKey];
	[cachedData retain];
	self.expiredCachedData = cachedData;
	
	// 2. if no cached data or force reload
	if ( !self.expiredCachedData || forceReload)
	{
		IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate showLoading:TRUE withText:@"資料讀取中"];
		
		NSString *url = [self getNewsRequestURL];
		self.appListFeedConnection = [URLConnectionManager getURLConnectionWithURL:url delegate:self];
		
		if (self.appListFeedConnection==nil)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"無法開啟網路連接" message:nil  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];	
			
			[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];		
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
				NSLog(@"auto reload %i", doAutoReload);
				if (doAutoReload)
				{
					[self loadNewsData:YES];
					break;				
				}
				// else go to default;
			default:
				// use cached data
				self.newsData = cachedData;
				[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];
				break;
		}
	}
	
	[cachedData release];
}

- (void)reloadAD
{
	if (self.adViewController)
	{
		[self.adViewController reload];
	}
}
// -------------------------------------------------------------------------------
//	handleLoadedApps:notif
// -------------------------------------------------------------------------------
- (void)handleLoadedApps
{
	if (self.newsData!=nil && [self.newsData count]>0)
	{
		NSArray *news = [self.newsData objectForKey:@"news"];
		self.newsListViewController.entries = news;
		[self.newsListViewController.tableView reloadData];
		[self setFooterLabel];
	}
}

- (void)setFooterLabel
{
	NSMutableString *updateTimeStr = [[NSMutableString alloc] initWithString:@"Updated："];
	[updateTimeStr appendString:[self.newsData objectForKey:@"updatetime"]];
	[self.footer.dateLabel setTitle:updateTimeStr forState:UIControlStateNormal];
	[updateTimeStr release];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods


// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how
// the connection object,  which is working in the background, can asynchronously communicate back to
// its delegate on the thread from which it was started - in this case, the main thread.
//

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
	doAutoReload = NO;
	
    self.appListFeedConnection = nil;   // release our connection
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"此功能需要網路連線" message:nil  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
	alert.tag=1000;
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
	
	if([status isEqualToString: @"0"] && data!=nil) { 
		self.newsData = data;
		[CacheManager cacheData:data withType:dataCacheKey];
	}
	else {
		if([status isEqualToString: @"3"]) { 
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"讀取資料錯誤" message:[data objectForKey:@"errdesc"]  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
			alert.tag=3000;
			[alert show];
			[alert release];
		}
		else 
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"讀取資料錯誤" message:[data objectForKey:@"errdesc"]  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
			alert.tag=2000;
			[alert show];
			[alert release];
		}
		[self setNewsData:self.expiredCachedData];
	}
	
	[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];		
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag==1000)
	{
		if (!self.newsData)
		{
			[self.navigationController popToRootViewControllerAnimated:YES];
		}
	}
	else if (alertView.tag==3000)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoginForm" object:nil userInfo:nil];
	}
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

- (void)showPreviousDetailNews:(int)indexPath withBackData:(NSArray*)backData   isRelatedNews:(BOOL)isRelatedNews
{
	if (indexPath > 0)
	{
		// create a new detail view
		--indexPath;
		NSLog(@"create new detail view begin");
		UIViewController *detailViewController = [self createNewsDetailViewControllerWithBackData:backData andIndex:indexPath isRelatedNews:isRelatedNews];
		[detailViewController retain];
		CGRect frame = detailViewController.view.frame;
		frame.origin = CGPointMake(-self.view.frame.size.width, 0.0 );// 0.0-self.navigationController.navigationBar.bounds.size.height);
		detailViewController.view.frame = frame;

		// slide out the previous
		UIViewController *top = [self.navigationController topViewController];
		CGRect outframe = top.view.frame;
		[UIView beginAnimations:@"slideOutToRight" context:detailViewController];
		[UIView setAnimationDidStopSelector:@selector(slideNews:finished:context:)];
		[UIView setAnimationDelegate:self];

		outframe.origin = CGPointMake(self.view.frame.size.width, 0.0);
		// outframe.origin = CGPointMake(320.0, 0.0);
		[UIView setAnimationDuration:kAnimationSpeed];
		top.view.frame = outframe;

		[UIView commitAnimations];
	}
}

- (void)slideNews:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	
	UIViewController *detailViewController = (UIViewController*)context;
	[self.navigationController popViewControllerAnimated:NO];
	[self.navigationController pushViewController:detailViewController animated:NO];
	[detailViewController release];
}

- (void)showNextDetailNews:(int)indexPath withBackData:(NSArray*)backData  isRelatedNews:(BOOL)isRelatedNews
{
	if (indexPath < [backData count]-1)
	{
		++indexPath;

		UIViewController *detailViewController = [self createNewsDetailViewControllerWithBackData:backData andIndex:indexPath isRelatedNews:isRelatedNews];
		[detailViewController retain];

		CGRect frame = detailViewController.view.frame;
		frame.origin = CGPointMake(self.view.frame.size.width, 0.0 );
		detailViewController.view.frame = frame;

		// slide out the previous
		UIViewController *top = [self.navigationController topViewController];
		CGRect outframe = top.view.frame;
		[UIView beginAnimations:@"slideOutToLeft" context:detailViewController];
		[UIView setAnimationDidStopSelector:@selector(slideNews:finished:context:)];
		[UIView setAnimationDelegate:self];
		
		outframe.origin = CGPointMake(-self.view.frame.size.width, 0.0);
		
		[UIView setAnimationDuration:kAnimationSpeed];
		top.view.frame = outframe;
		
		[UIView commitAnimations];
	}
} 

- (void)showDetailNews:(int)indexPath withBackData:(NSArray*)backData popPreviousView:(BOOL)pop  isRelatedNews:(BOOL)isRelatedNews
{
	if (pop) {
		[self.navigationController popViewControllerAnimated:NO];
	}
	
	UIViewController *detailViewController = [self createNewsDetailViewControllerWithBackData:backData andIndex:indexPath isRelatedNews:isRelatedNews];
	[detailViewController retain];
		
	[self.navigationController setToolbarHidden:NO animated:NO];
	[self.navigationController pushViewController:detailViewController animated:YES];	
	
	[detailViewController release];
}

- (UIViewController*)createNewsDetailViewControllerWithBackData:(NSArray*)backData andIndex:(int)indexPath isRelatedNews:(BOOL)isRelatedNews
{
	NewsDetailViewController *detailViewController = [[[NewsDetailViewController alloc] initWithNibName:@"NewsDetailViewController" bundle:nil] autorelease];
	detailViewController.hidesBottomBarWhenPushed = YES;
	detailViewController.delegate = self;
	detailViewController.backData = backData;
	detailViewController.indexPath = indexPath;
	if (isRelatedNews)
	{
		detailViewController.isRelatedNews = YES;
		detailViewController.title = [NSString stringWithFormat:@"相關新聞 (%i/%i)",indexPath+1,[backData count]];
	}
	else {
		detailViewController.title = [NSString stringWithFormat:titleTemplate,indexPath+1,[backData count]];
	}

	return detailViewController;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	NSLog(@"======================= called from viewWillAppear");	
	[self loadNewsData:NO];
	
	
	if ([self.newsListViewController.tableView numberOfSections]>0 && [self.newsListViewController.tableView numberOfRowsInSection:0]>0)
		[self.newsListViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)didLoadAD:(BOOL)show
{
	int position = 0;
	int newsListViewHeight = kDefaultNewsListHeight;
		
	if (show)
	{
		[UIView beginAnimations:@"showAD" context:nil];
		[UIView setAnimationDuration:kAnimationSpeed];

		if (self.adViewController)
		{
			adViewController.view.frame = CGRectMake(0, 0, adViewController.view.frame.size.width, kDefaultADHeight);
			
			position += self.adViewController.view.frame.size.height;
			newsListViewHeight -= self.adViewController.view.frame.size.height;
		}
		
		self.newsListViewController.view.frame = CGRectMake(0, position, newsListViewController.view.frame.size.width, newsListViewHeight);
		[UIView commitAnimations];
	}
	else {
		[UIView beginAnimations:@"hideAD" context:nil];
		[UIView setAnimationDuration:kAnimationSpeed];
		
		if (self.adViewController)
		{  
			self.adViewController.view.frame = CGRectMake(0, 0, adViewController.view.frame.size.width, 0);
		}
		
		self.newsListViewController.view.frame = CGRectMake(0, position, newsListViewController.view.frame.size.width, newsListViewHeight);
		[UIView commitAnimations];
	}

}

- (void)dealloc {
	[adViewController release];
	[newsListViewController release];
	[footer release];

	[newsData release];
	[expiredCachedData release];

	[dateformatter release];
	[requestKey release];
	
    [appListFeedConnection release];
	[appListData release];

	[dataCacheKey release];
	[titleTemplate release];

    [super dealloc];
}

@end
