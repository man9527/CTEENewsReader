//
//  NewsDetailViewController.m
//  IBENewsReader
//
//  Created by man9527 on 2011/1/1.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "CacheManager.h"
#import "IconDownloader.h"
static NSString *imagekey = @"img";
static NSString *savedImageKey = @"savetimg";

@implementation NewsDetailViewController
@synthesize delegate,container,indexPath,maintitle,subtitle,ddate, authur, imageView, content, news,iconDownloader;
@synthesize relatedNewsData, relatedNewsView, backData;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.news = [self.backData objectAtIndex:indexPath];
	
	NSString *originalContent = [self.news objectForKey:@"content"];
	NSMutableString *tempContent = [NSMutableString stringWithString:originalContent];
	[tempContent replaceOccurrencesOfString:@"<p>" withString:@"\n\r" options:NSLiteralSearch range:NSMakeRange(0, [tempContent length])];
	
	[self.content setText:tempContent];
	CGRect c = self.content.frame;
	c.size.height = self.content.contentSize.height;
	self.content.frame = c;
	
	[self.maintitle setText:[self.news objectForKey:@"title"]];
	self.maintitle.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);
	UIFont *font = [UIFont boldSystemFontOfSize:24.0f];
	self.maintitle.font = font;
	CGRect c1 = self.maintitle.frame;
	c1.size.height = self.maintitle.contentSize.height;
	self.maintitle.frame = c1;
	
	[self.subtitle setText:[self.news objectForKey:@"subtitle"]];
	CGRect c2 = self.subtitle.frame;
	c2.size.height = self.subtitle.contentSize.height;
	self.subtitle.frame = c2;
	self.subtitle.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);
	
	[self.authur setText:[self.news objectForKey:@"author"]];
	CGRect c3 = self.authur.frame;
	c3.size.height = self.authur.contentSize.height;
	self.authur.frame = c3;	
	self.authur.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);

	[self.ddate setText:[self.news objectForKey:@"yyyymmdd"]];
	self.ddate.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);

	[self setRelatedNews];
	[self loadNewsImage];

	[self resizeContent];

	[self setGesture];
	NSLog(@"view did load done");
}

- (void)setRelatedNews
{
	self.relatedNewsData = [news objectForKey:@"related"];
	
	if (self.relatedNewsData!=nil)
	{
		self.relatedNewsView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		self.relatedNewsView.delegate = self;
		self.relatedNewsView.dataSource = self;
		self.relatedNewsView.backgroundColor = [UIColor clearColor];
		self.relatedNewsView.bounces = NO;
		[self.relatedNewsView reloadData];
		
		self.relatedNewsView.frame = CGRectMake(0, self.container.frame.size.height , 300, self.relatedNewsView.contentSize.height);

		[self.container addSubview:self.relatedNewsView];
	}
	
}

- (void)setGesture
{
	UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveToPreviousNews)];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	swipeRight.delegate = self;
	[self.container addGestureRecognizer:swipeRight];
	
	UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveToNextNews)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	swipeLeft.delegate = self;
	[self.container addGestureRecognizer:swipeLeft];	
	
	[swipeRight release];
	[swipeLeft release];
}

- (void)loadNewsImage
{
	if ( [news objectForKey:imagekey]!=nil )
	{
		UIImage *image = [news objectForKey:savedImageKey];

		if (image)
		{
			[self setImageViewHeight:self.imageView ByImage:image];
			[self.imageView setImage:image];
		}
		else
		{
			image = [CacheManager getCachedImage:[news objectForKey:imagekey]];
			
			if (image) {
				[self setImageViewHeight:self.imageView ByImage:image];
				[imageView setImage:image];
			} 
			else {
				[self setImageViewHeight:self.imageView ByImage:nil];
				[self startIconDownload:news];
			}
		}
	}
	else {
		[self setImageViewHeight:self.imageView ByImage:nil];
	}
}

- (void)resizeContent
{
	NSArray *viewList = [[NSArray alloc] initWithObjects:
					 self.maintitle, self.subtitle, self.ddate, self.authur, self.imageView, self.content, self.relatedNewsView, nil
					 ];
	
	int space = 0;
	int ypos = 0;
	
	for (UIView *view in viewList) {
		[self resetFrame:view withY:ypos];
		ypos += view.frame.size.height;
		ypos += space;
	}

	[self.container setContentSize:CGSizeMake(container.frame.size.width, ypos)];
	[viewList release];
}

-(void)resetFrame:(UIView*)view withY:(int)y
{
	view.frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);		
}

- (void)startIconDownload:(NSMutableDictionary *)newsRecord 
{
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
		iconDownloader.newsRecord = newsRecord;
		iconDownloader.imageType = imagekey;
		iconDownloader.savedImageType = savedImageKey;
		iconDownloader.imageHeight = 300;
        iconDownloader.delegate = self;
        [iconDownloader startDownload];
    }
}

- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
	UIImage *image = [iconDownloader.newsRecord objectForKey:savedImageKey];
	[CacheManager cacheImage:image withName:[iconDownloader.newsRecord objectForKey:imagekey]];
	
	[self setImageViewHeight:self.imageView ByImage:image];
	
	[imageView setImage:image];
	[self resizeContent];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(void)moveToPreviousNews
{
	[delegate showPreviousDetailNews:self.indexPath withBackData:self.backData isRelatedNews:NO];
}

-(void)moveToNextNews
{
	[delegate showNextDetailNews:self.indexPath withBackData:self.backData isRelatedNews:NO];
}

#pragma mark implement UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = [self.relatedNewsData count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath2
{
	static NSString *CellIdentifier = @"RelatedTableCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
	
    // Leave cells empty if there's no data yet
	int nodeCount = [self.relatedNewsData count];
    if (nodeCount > 0)
	{
		NSMutableDictionary *newsRecord = [self.relatedNewsData objectAtIndex:indexPath2.row]; 
		cell.textLabel.text = [newsRecord objectForKey:@"title"];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"相關新聞";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath2
{
	[delegate showDetailNews:indexPath2.row withBackData:self.relatedNewsData popPreviousView:YES  isRelatedNews:YES];
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

-(void)setImageViewHeight:(UIImageView*)view ByImage:(UIImage*)image
{
	if (image)
	{
		CGRect frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, image.size.height);		
		view.frame = frame;
		view.clipsToBounds = YES;
		NSLog(@"size: %i",view.frame.size.height);
	}
	else {
		view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 0);		
	}
}

- (void)dealloc {
	[iconDownloader release];   
	[container release];
	[maintitle release];
	[subtitle release];
	[ddate release];
	[authur release];
	[imageView release];
	[content release];
	[relatedNewsView release];
	[news release];
	[backData release];
	[relatedNewsData release];
	
    [super dealloc];
}


@end
