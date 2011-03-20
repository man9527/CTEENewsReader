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
#import "UserService.h"
static NSString *imagekey = @"img";
static NSString *savedImageKey = @"savetimg";

@implementation NewsDetailViewController
@synthesize delegate,container,indexPath,maintitle,subtitle,ddate, authur, imageView, content, news,iconDownloader;
@synthesize relatedNewsData, relatedNewsView, backData, fontSize, isRelatedNews;
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

	User *user = [UserService currentLogonUser];
	fontSize = user.fontSize;

	UIBarButtonItem *btnPrev = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moveToPreviousNews)];
	UIBarButtonItem *btnNext = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moveToNextNews)];
	UIBarButtonItem *fontIncrease = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"font_increse.png"] style:UIBarButtonItemStylePlain target:self action:@selector(zoomIn)];
	UIBarButtonItem *fontDecrease = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"font_decrese.png"] style:UIBarButtonItemStylePlain target:self action:@selector(zoomOut)];

	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	NSArray *itemsArray = [[NSArray alloc] initWithObjects:btnPrev, flexibleSpace, fontDecrease, flexibleSpace, fontIncrease, flexibleSpace, btnNext, nil ];
	[self setToolbarItems:itemsArray animated:NO];
	
	[btnPrev release]; [btnNext release]; [flexibleSpace release], [itemsArray release];
	[fontIncrease release]; [fontDecrease release];
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
		[self composeTextVewBlock:(UITextView*)self.content withContent:(NSString*)tempContent andFontSize:[UIFont systemFontOfSize:fontSize]];
	}

	[self composeTextVewBlock:(UITextView*)self.maintitle withContent:(NSString*)lmaintitle andFontSize:[UIFont boldSystemFontOfSize:(fontSize+12.0f)]];
	[self composeTextVewBlock:(UITextView*)self.subtitle withContent:(NSString*)lsubtitle andFontSize:[UIFont systemFontOfSize:(fontSize+6.0f)]];

	if (![lddate isEqual:[NSNull null]])
	{
		NSRange blankPosition = [lddate rangeOfString:@" "];
		NSString *dateString = [lddate substringToIndex:blankPosition.location+1];
		
		if (![lauthor isEqual:[NSNull null]])
		{
			dateString = [dateString stringByAppendingString:lauthor];
		}
		[self composeTextVewBlock:(UITextView*)self.ddate withContent:(NSString*)dateString andFontSize:[UIFont systemFontOfSize:(fontSize-2.0f)]];
	}	

	[self setRelatedNews];
	[self loadNewsImage];
	[self resizeContent];
	[self setGesture];
}

- (void)composeTextVewBlock:(UITextView*)textView withContent:(NSString*)text andFontSize:(UIFont*)font
{
	if (text && ![text isEqual:[NSNull null]])
	{
		[textView setText:text];
	}
	
	textView.font = font;
	CGRect c1 = textView.frame;
	c1.size.height = textView.contentSize.height;
	textView.frame = c1;
}

- (void)setRelatedNews
{
	self.relatedNewsData = [news objectForKey:@"related"];
	
	if ( self.relatedNewsData && ![self.relatedNewsData isEqual:[NSNull null]])
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
	if ( ![[news objectForKey:imagekey] isEqual:[NSNull null]] )
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
	[self.container scrollsToTop];		

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

-(void)moveToPreviousNews
{
	[delegate showPreviousDetailNews:self.indexPath withBackData:self.backData isRelatedNews:isRelatedNews];
}


-(void)moveToNextNews
{
	[delegate showNextDetailNews:self.indexPath withBackData:self.backData isRelatedNews:isRelatedNews];
}

-(void)zoomIn
{
	if (fontSize < 28.0f) {
		fontSize+=1.0f;
		[self.container setContentSize:CGSizeMake(container.frame.size.width, 0)];
		[self composeTextVewBlock:(UITextView*)self.maintitle withContent:(NSString*)self.maintitle.text andFontSize:[UIFont boldSystemFontOfSize:(fontSize+12.0f)]];
		[self composeTextVewBlock:(UITextView*)self.subtitle withContent:(NSString*)self.subtitle.text andFontSize:[UIFont systemFontOfSize:(fontSize+6.0f)]];
		[self composeTextVewBlock:(UITextView*)self.ddate withContent:(NSString*)self.ddate.text andFontSize:[UIFont systemFontOfSize:(fontSize-2.0f)]];
		[self composeTextVewBlock:(UITextView*)self.content withContent:(NSString*)self.content.text andFontSize:[UIFont systemFontOfSize:(fontSize)]];
		[self resizeContent];
		[self saveFontSize];
	}
}


-(void)zoomOut
{
	if (fontSize > 16.0f) {
		fontSize-=1.0f;
		[self.container setContentSize:CGSizeMake(container.frame.size.width, 0)];
		[self composeTextVewBlock:(UITextView*)self.maintitle withContent:(NSString*)self.maintitle.text andFontSize:[UIFont boldSystemFontOfSize:(fontSize+12.0f)]];
		[self composeTextVewBlock:(UITextView*)self.subtitle withContent:(NSString*)self.subtitle.text andFontSize:[UIFont systemFontOfSize:(fontSize+6.0f)]];
		[self composeTextVewBlock:(UITextView*)self.ddate withContent:(NSString*)self.ddate.text andFontSize:[UIFont systemFontOfSize:(fontSize-2.0f)]];
		[self composeTextVewBlock:(UITextView*)self.content withContent:(NSString*)self.content.text andFontSize:[UIFont systemFontOfSize:(fontSize)]];
		[self resizeContent];
		[self saveFontSize];
	}	
}

-(void)saveFontSize
{
	User *user = [UserService currentLogonUser];
	user.fontSize = fontSize;
	[UserService saveUserLocal:user];
}

#pragma mark implement UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.relatedNewsData && ![self.relatedNewsData isEqual:[NSNull null]])
	{
		return 1;
	}
	else {
		NSLog(@"related news section no");
		return 0;
	}

}

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
