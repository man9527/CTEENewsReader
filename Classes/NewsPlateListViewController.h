//
//  NewsPlateListViewController.h
//  IBENewsReader
//
//  Created by William Chu on 2011/1/6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsPlateListViewController : UITableViewController <UIAlertViewDelegate, UINavigationControllerDelegate>{
	NSMutableArray *entries;   // the main data model for our UITableView
	NSMutableArray *plateName;
	NSString *NewsTypeName;
	
	NSDictionary			*newsData;
	NSDictionary			*expiredCachedData;
	NSDateFormatter			*dateformatter; 

    NSURLConnection         *appListFeedConnection;
    NSMutableData           *appListData;
	NSString				*cachekey;
}

@property (nonatomic, retain) NSMutableArray *entries;
@property (nonatomic, retain) NSMutableArray *plateName;
@property (nonatomic, retain) NSDictionary	*expiredCachedData;
@property (nonatomic, retain) NSDictionary	*newsData;
@property (nonatomic, retain) NSDateFormatter *dateformatter; 
@property (nonatomic, retain) NSURLConnection *appListFeedConnection;
@property (nonatomic, retain) NSMutableData *appListData;
@property (nonatomic, retain) NSString *cachekey;

- (void)loadNewsData:(bool)forceReload;
- (NSString*)getNewsRequestURL;
- (void)handleNewsData:(NSDictionary*)data;
// - (void)handleLoadedApps;
@end
