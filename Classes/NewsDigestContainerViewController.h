//
//  NewsDigestContainerViewController.h
//  IBENewsReader
//
//  Created by William Chu on 2010/12/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingIndustryViewController.h"
#import "NewsListViewController.h"
#import "ADViewController.h"
#import "NewsListFooterViewController.h"
  
@interface NewsDigestContainerViewController : UIViewController <NewsReloadDelegate, UIAlertViewDelegate,NewsDetailDelegate> {

	IBOutlet ADViewController *adViewController;
	IBOutlet NewsListViewController *newsListViewController;
	IBOutlet NewsListFooterViewController *footer;

    // the list of news shared with "NewsDigestNewsListViewController"
	NSDictionary			*newsData;
	NSDictionary			*expiredCachedData;
    
    NSURLConnection         *appListFeedConnection;
    NSMutableData           *appListData;
	
	NSDateFormatter *dateformatter; 
	NSString *requestKey;

	NSString *NewsTypeName; // = @"SelectedNews";
	NSString *titleTemplate; // = @"精選(%i/%i)";
	NSString *selfTitle; // = @"工商時報 %@ 精選";
	NSString *dataCacheKey;
}

@property(nonatomic,retain) IBOutlet	SettingIndustryViewController *industryViewController;
@property(nonatomic,retain) IBOutlet	ADViewController *adViewController;
@property(nonatomic,retain) IBOutlet	NewsListViewController *newsListViewController;
@property(nonatomic,retain) IBOutlet	NewsListFooterViewController *footer;

// @property(nonatomic,assign) id delegate;

@property (nonatomic, retain) NSURLConnection *appListFeedConnection;
@property (nonatomic, retain) NSMutableData *appListData;
@property (nonatomic, retain) NSDateFormatter *dateformatter; 
@property (nonatomic, retain) NSDictionary *newsData; 
@property (nonatomic, retain) NSDictionary *expiredCachedData; 
@property (nonatomic, retain) NSString *requestKey;

@property (nonatomic, retain) NSString *selfTitle;
@property (nonatomic, retain) NSString *titleTemplate;
@property (nonatomic, retain) NSString *dataCacheKey;

- (void)initSubViews;
- (void)layoutSubViews;
- (void)handleNewsData:(NSDictionary*)newsData;
- (void)setFooterLabel;
- (UIViewController*)createNewsDetailViewControllerWithBackData:(NSArray*)backData andIndex:(int)indexPath  isRelatedNews:(BOOL)isRelatedNews;
- (NSString*)getNewsRequestURL;
- (void)setupStaticKeyString;

@end
