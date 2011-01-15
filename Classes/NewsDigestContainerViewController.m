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

// static NSString *const TopPaidAppsFeed = @"https://d9.ctee.com.tw/m/headnewsbyplate.aspx?username=ctee&authkey=dffe744e-a091-45e6-884c-f4ecdb100316";
// static NSString *NewsTypeName = @"SelectedNews";
// static NSString *titleTemplate = @"精選(%i/%i)";
// static NSString *selfTitle = @"工商時報 %@ 精選";

// @"https://d9.ctee.com.tw/m/headnewsbyplate.aspx?username=ctee&authkey=xxxxxxxx";
// @"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml";

@implementation NewsDigestContainerViewController
@synthesize adViewController, industryViewController, appListFeedConnection, appListData,newsListViewController, footer;
@synthesize dateformatter, newsData, expiredCachedData, requestKey, selfTitle, titleTemplate;
@synthesize dataCacheKey;

- (void)awakeFromNib {
	NSLog(@"awake from nib");

	[self setupStaticKeyString];
	[self initSubViews];
	
	dateformatter = [[NSDateFormatter alloc] init]; 
	[self.dateformatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];	
}

- (void)viewDidLoad {

    [super viewDidLoad];

	self.dataCacheKey = [NewsTypeName stringByAppendingString:requestKey];
	self.navigationItem.title = selfTitle; // [NSString stringWithFormat:selfTitle, [dateStr substringToIndex:10]];

	[self layoutSubViews];
	[self loadNewsData:false];
}  

#pragma mark need to override these methods
- (void)initSubViews
{
	self.adViewController = [[ADViewController alloc] initWithNibName:@"ADViewController" bundle:nil adpath:@"advertisement-selected"];

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
}

- (NSString*)getNewsRequestURL
{
	User *user = [UserService currentLogonUser];
	NSLog(@"uuu %@", user.username);
	NSLog(@"ppp %@", user.password);
	NSString *url = [URLManager getNewsByPlateURLForUser:user withPlate:@"A01AA1"];
	return url;
}

- (void)setupStaticKeyString
{
	NewsTypeName = @"SelectedNews";
	titleTemplate = @"精選(%i/%i)";
	selfTitle = @"工商時報 %@ 精選";
}

- (void)loadNewsData:(bool)forceReload
{
	// 1. load data from cache
	NSDictionary *cachedData = [CacheManager getCachedData:dataCacheKey];
	[cachedData retain];
	self.expiredCachedData = cachedData;
	
	// 2. if no cached data or force reload
	if (cachedData==nil || forceReload)
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
				//[cachedData release];
				//[expiredCachedData release];
				[self loadNewsData:YES];
				break;				
			default:
				// use cached data
				self.newsData = cachedData;
				[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];
				break;
		}
	}
	
	[cachedData release];
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

// -------------------------------------------------------------------------------
//	handleError:error
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Top Paid Apps"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

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
    
	//NSString* json_string = [[NSString alloc] initWithData:appListData encoding:NSUTF8StringEncoding];
	NSString* json_string =
	@"{\"status\":\"0\",	   \"errdesc\":null,	   \"updatetime\":\"2012/12/31 08:00:00\",	   \"invalidtime\":\"2012/12/31 22:00:00\",	   \"news\":[{\"clipid\":662999,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A1 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\",\"content\":\"content打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲打炒匯巨鱷央行祭重砲\", \"thumb\":\"http://www.williamlong.info/upload/2427_3.jpg\", \"img\":\"http://blog.lib.umn.edu/rade0117/architecture/baby.jpg\"}, 	{\"clipid\":663000,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A2 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 2\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\", \"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\",\"thumb\":\"http://designexcite.com/images/s-logo.png\",\"img\":\"http://www.thefrogandtheprincess.com/Images/baby-aspen-welcome-home-baby-blue-set-2.jpg\",\"related\":[{\"clipid\":663001,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A2 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 3\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\", \"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\",\"img\":\"http://designexcite.com/images/s-logo.png\"},{\"clipid\":663001,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A2 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 4\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\", \"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\",\"img\":\"http://designexcite.com/images/s-logo.png\"}] }, {\"clipid\":662999,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A1 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 5\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\",\"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\", \"thumb\":\"http://www.williamlong.info/upload/2427_3.jpg\", \"img\":\"http://blog.lib.umn.edu/rade0117/architecture/baby.jpg\"}, {\"clipid\":662999,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A1 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 6\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\",\"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\", \"thumb\":\"http://www.williamlong.info/upload/2427_3.jpg\", \"img\":\"http://blog.lib.umn.edu/rade0117/architecture/baby.jpg\"}, {\"clipid\":662999,\"yyyymmdd\":\"2011/1/1\",\"plate\":\"A01AA1\",\"platename\":\"A1 要聞\",\"author\":\"A1 要聞\",\"title\":\"打炒匯巨鱷央行祭重砲 7\",\"subtitle\":\"|實施間接熱錢稅，加重炒作成本；金管會亦成立專案小組，徹查異常資金\",\"content\":\"打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒打炒匯巨鱷央行祭重砲打炒\", \"thumb\":\"http://www.williamlong.info/upload/2427_3.jpg\", \"img\":\"http://blog.lib.umn.edu/rade0117/architecture/baby.jpg\"}]}";

	// NSLog(@"%@",json_string);
	
	NSDictionary *jsonObj = [json_string JSONValue];
	[jsonObj retain];
	[self handleNewsData:jsonObj];
    self.appListData = nil;
	
	[jsonObj release];
}

- (void)handleNewsData:(NSDictionary*)data
{
	NSString *status = [data objectForKey:@"status"];
	if([status isEqualToString: @"0"]) { 
		if (data!=nil)
		{
			self.newsData = data;
			[CacheManager cacheData:data withType:dataCacheKey];
		}
		else if (self.expiredCachedData!=nil)
		{
			[self setNewsData:self.expiredCachedData];
		}
		else {
			[self setNewsData:nil];
		}

		[self performSelectorOnMainThread:@selector(handleLoadedApps) withObject:nil waitUntilDone:NO];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"讀取資料錯誤" message:[data objectForKey:@"errdesc"]  delegate:self  cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
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
	//[self.navigationController.view addSubview:detailViewController.view] ; // animated:NO];
/*
	NSLog(@"slide in new view begin");
	CGRect frame = detailViewController.view.frame;
	frame.origin = CGPointMake(0.0, 0.0);
	
	[UIView beginAnimations:@"slideIn" context:nil];
	[UIView setAnimationDuration:kAnimationSpeed];

	detailViewController.view.frame = frame;
    
	[UIView commitAnimations];
	
	[detailViewController release];
	NSLog(@"slide in new view done");
*/	
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

	[self.navigationController pushViewController:detailViewController animated:YES];
	 
	[detailViewController release];
	NSLog(@"detail view retain count %i",[detailViewController retainCount]);
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
		detailViewController.title = [NSString stringWithFormat:@"相關新聞 (%i/%i)",indexPath+1,[backData count]];
	}
	else {
		detailViewController.title = [NSString stringWithFormat:titleTemplate,indexPath+1,[backData count]];
	}

	return detailViewController;
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
