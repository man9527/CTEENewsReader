//
//  NewsListViewController.m
//  IBENewsReader
//
//  Created by William Chu on 2010/12/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewsListViewController.h"
#import "CacheManager.h"
#import "NewsDetailViewController.h"
#import "IBENewsReaderAppDelegate.h"

#define kCustomRowHeight    95.0
#define kCustomRowCount     4

// #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSString *imagekey = @"thumb";
static NSString *savedImageKey = @"savethumb";

@interface NewsListViewController ()
- (void)startIconDownload:(NSDictionary *)newsRecord forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation NewsListViewController
@synthesize entries, delegate;
@synthesize imageDownloadsInProgress;

#pragma mark 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
}

- (void)dealloc
{
    [entries release];
	[imageDownloadsInProgress release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

#pragma mark -
#pragma mark Table view creation (UITableViewDataSource)

// customize the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = [entries count];
	
	if (count==0)
	{
		return 1;
	}
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([entries count]>0)
	{
		IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	
		if ( [appDelegate validateForPaidUser] ) {
			[delegate showDetailNews:indexPath.row withBackData:self.entries popPreviousView:NO isRelatedNews:NO];
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// customize the appearance of table view cells
	//
	static NSString *CellIdentifier = @"LazyTableCell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.entries count];
	
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:PlaceholderCellIdentifier] autorelease];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
		
		cell.detailTextLabel.text = @"尚無資料";
		
		return cell;
    }
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle	reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		// cell.selectedBackgroundView = selectedBackground;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;		
    }
	
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Set up the cell...
		NSMutableDictionary *newsRecord = [self.entries objectAtIndex:indexPath.row]; 
        cell.accessoryView = nil;
		cell.textLabel.text = [newsRecord objectForKey:@"title"];
		//UIFont *font = [UIFont boldSystemFontOfSize:22.0f];
		//cell.textLabel.font = font;

		cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
		cell.textLabel.textColor = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
		cell.textLabel.numberOfLines = 1; //2;

		NSString *subtitle = [newsRecord objectForKey:@"subtitle"];

		if (![subtitle isEqual:[NSNull null]])
		{
			cell.detailTextLabel.text = subtitle;
		}
		else {
			cell.detailTextLabel.text = [newsRecord objectForKey:@"content"];
		}
		
		cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;// UILineBreakModeTailTruncation;
		cell.detailTextLabel.textColor = [UIColor colorWithRed:104.0f/255.0f green:104.0f/255.0f blue:104.0f/255.0f alpha:1.0f];
		cell.detailTextLabel.numberOfLines = 2;
		
        // Only load cached images; defer new downloads until scrolling ends
		// first: get from memory

		if ( ![[newsRecord objectForKey:imagekey] isEqual:[NSNull null]] )
		{
			if ([newsRecord objectForKey:savedImageKey])
			{
				UIImageView *imageView = [[UIImageView alloc] initWithImage:[newsRecord objectForKey:savedImageKey]];
				cell.accessoryView = imageView;
				[imageView release];
			}
			else
			{
				UIImage *image = [CacheManager getCachedImage:[newsRecord objectForKey:imagekey]];

				if (image!=nil) {
					UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
					cell.accessoryView = imageView;
					[imageView release];
				} 
				else {
					if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
					{
						[self startIconDownload:newsRecord forIndexPath:indexPath];
					}
				}			
			}
		}
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table cell image support

// - (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
- (void)startIconDownload:(NSMutableDictionary *)newsRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
		iconDownloader.newsRecord = newsRecord;
		iconDownloader.imageType = imagekey;
		iconDownloader.savedImageType = savedImageKey;
		iconDownloader.imageHeight = 75;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
			NSMutableDictionary *newsRecord = [self.entries objectAtIndex:indexPath.row]; 
            
            if ( ![[newsRecord objectForKey:imagekey] isEqual:[NSNull null]] && [newsRecord objectForKey:savedImageKey]==nil) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:newsRecord forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
		// cache image
		[CacheManager cacheImage:[iconDownloader.newsRecord objectForKey:savedImageKey] withName:[iconDownloader.newsRecord objectForKey:imagekey]];
		
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
		UIImage *img = [iconDownloader.newsRecord objectForKey:savedImageKey];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
		cell.accessoryView = imageView;
		[imageView release];
    }
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end