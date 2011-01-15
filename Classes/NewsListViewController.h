//
//  NewsListViewController.h
//  IBENewsReader
//
//  Created by William Chu on 2010/12/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"
#import "NewsDetailViewController.h"

@interface NewsListViewController : UITableViewController  <UIScrollViewDelegate, IconDownloaderDelegate> {
	NSArray *entries;   // the main data model for our UITableView
    NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each app
	id<NewsDetailDelegate> delegate;
}

@property (nonatomic, retain) NSArray *entries;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, assign) id<NewsDetailDelegate> delegate;

- (void)appImageDidLoad:(NSIndexPath *)indexPath;
@end
