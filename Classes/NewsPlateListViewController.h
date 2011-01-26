//
//  NewsPlateListViewController.h
//  IBENewsReader
//
//  Created by William Chu on 2011/1/6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsListFooterViewController.h"

@interface NewsPlateListViewController : UIViewController <UIAlertViewDelegate, UINavigationControllerDelegate, NewsReloadDelegate, UITableViewDelegate, UITableViewDataSource>{

	IBOutlet NewsListFooterViewController *footer;
	IBOutlet UITableView *listTableView;
	NSMutableArray *entries;   // the main data model for our UITableView
	NSMutableArray *plateName;
	NSString *NewsTypeName;
	
	BOOL doAutoReload;
	
	NSDictionary			*newsData;
	NSDictionary			*expiredCachedData;
	NSDateFormatter			*dateformatter; 

    NSURLConnection         *appListFeedConnection;
    NSMutableData           *appListData;
	NSString				*cachekey;
	
	NSMutableDictionary		*cachedControllers;
}
@property(nonatomic,retain) IBOutlet	NewsListFooterViewController *footer;
@property(nonatomic,retain) IBOutlet UITableView *listTableView;

@property(nonatomic,assign) BOOL doAutoReload;

@property (nonatomic, retain) NSMutableArray *entries;
@property (nonatomic, retain) NSMutableArray *plateName;
@property (nonatomic, retain) NSDictionary	*expiredCachedData;
@property (nonatomic, retain) NSDictionary	*newsData;
@property (nonatomic, retain) NSDateFormatter *dateformatter; 
@property (nonatomic, retain) NSURLConnection *appListFeedConnection;
@property (nonatomic, retain) NSMutableData *appListData;
@property (nonatomic, retain) NSString *cachekey;
@property (nonatomic, retain) NSMutableDictionary		*cachedControllers;

- (void)loadNewsData:(bool)forceReload;
- (NSString*)getNewsRequestURL;
- (void)handleNewsData:(NSDictionary*)data;
- (void)setFooterLabel;
@end
