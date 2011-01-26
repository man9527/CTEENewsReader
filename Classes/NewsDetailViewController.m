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

	UIBarButtonItem *btnPrev = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moveToPreviousNews)];
	UIBarButtonItem *btnNext = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moveToNextNews)];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	NSArray *itemsArray = [[NSArray alloc] initWithObjects:btnPrev, flexibleSpace, btnNext, nil ];
	[self setToolbarItems:itemsArray animated:NO];
	
	[btnPrev release]; [btnNext release]; [flexibleSpace release], [itemsArray release];
	
	self.news = [self.backData objectAtIndex:indexPath];
	
	NSString *originalContent = [self.news objectForKey:@"content"];
	NSString *lmaintitle = [self.news objectForKey:@"title"];
	NSString *lsubtitle = [self.news objectForKey:@"subtitle"];
	NSString *lauthor = [self.news objectForKey:@"author"];
	NSString *lddate = [self.news objectForKey:@"yyyymmdd"];

	if (![originalContent isEqual:[NSNull null]])
	{
		NSMutableString *tempContent = [NSMutableString stringWithString:originalContent];
		[tempContent replaceOccurrencesOfString:@"<p>" withString:@"\n\r" options:NSLiteralSearch range:NSMakeRange(0, [tempContent length])];
		[self.content setText:tempContent];
	}

	CGRect c = self.content.frame;
	c.size.height = self.content.contentSize.height;
	self.content.frame = c;
	
	if (![lmaintitle isEqual:[NSNull null]])
	{
		[self.maintitle setText:lmaintitle];
	}
	self.maintitle.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);
	UIFont *font = [UIFont boldSystemFontOfSize:24.0f];
	self.maintitle.font = font;
	CGRect c1 = self.maintitle.frame;
	c1.size.height = self.maintitle.contentSize.height;
	self.maintitle.frame = c1;
	
	if (![lsubtitle isEqual:[NSNull null]])
	{
		[self.subtitle setText:lsubtitle];
	}
	self.subtitle.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);
	UIFont *font2 = [UIFont systemFontOfSize:20.0f];
	self.subtitle.font=font2;
	CGRect c2 = self.subtitle.frame;
	c2.size.height = self.subtitle.contentSize.height;
	self.subtitle.frame = c2;
	
	CGRect c3 = self.authur.frame;
	c3.size.height = self.authur.contentSize.height;
	self.authur.frame = c3;	
	self.authur.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);

	if (![lddate isEqual:[NSNull null]])
	{
		NSRange blankPosition = [lddate rangeOfString:@" "];
		NSString *dateString = [lddate substringToIndex:blankPosition.location+1];
		
		if (![lauthor isEqual:[NSNull null]])
		{
			dateString = [dateString stringByAppendingString:lauthor];
		}
		[self.ddate setText:dateString];
	}	
	CGRect c4 = self.ddate.frame;
	c4.size.height = self.ddate.contentSize.height;
	self.ddate.frame = c4;		
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
	//[self.view addGestureRecognizer:swipeRight];
	[self.container addGestureRecognizer:swipeRight];
	
	UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveToNextNews)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	swipeLeft.delegate = self;
	// [self.view addGestureRecognizer:swipeLeft];	
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

		if (view.frame.size.height>0.0)
		{
			ypos += view.frame.size.height;
			ypos += space;
		}
	}

	if (ypos < 436.0)
		ypos = 436.0;
	
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
 - (IBAction)moveToPreviousNews:(id)sender;
 {
 [delegate showPreviousDetailNews:self.indexPath withBackData:self.backData isRelatedNews:NO];
 }
 - (IBAction)moveToNextNews:(id)sender;
 {
 [delegate showNextDetailNews:self.indexPath withBackData:self.backData isRelatedNews:NO];
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
	// need to cancel download if it is still downloading
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
	[iconDownloader cancelDownload];	
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
