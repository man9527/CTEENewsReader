//
//  NewsDetailViewController.h
//  IBENewsReader
//
//  Created by man9527 on 2011/1/1.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"
@protocol NewsDetailDelegate;

@interface NewsDetailViewController : UIViewController <UIGestureRecognizerDelegate,IconDownloaderDelegate,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource>{
	id<NewsDetailDelegate> delegate;

	IBOutlet UIScrollView *container;
	int index;
	IBOutlet UITextView *maintitle;
	IBOutlet UITextView *subtitle;
	IBOutlet UITextView *ddate;
	IBOutlet UITextView *authur;
	IBOutlet UIImageView *imageView;
	IBOutlet UITextView *content;
	IBOutlet UITableView *relatedNewsView;	
	NSMutableDictionary *news;
	NSArray *backData;
	NSArray *relatedNewsData;

	float fontSize;
	IconDownloader *iconDownloader;
	BOOL isRelatedNews;
}

@property(nonatomic,assign) id<NewsDetailDelegate> delegate;
@property(nonatomic,retain) 	IBOutlet UIScrollView *container;
@property(nonatomic,assign) 	int indexPath;
@property(nonatomic,retain) 	IBOutlet UITextView *maintitle;
@property(nonatomic,retain) 	IBOutlet UITextView *subtitle;
@property(nonatomic,retain) 	IBOutlet UITextView *ddate;
@property(nonatomic,retain) 	IBOutlet UITextView *authur;
@property(nonatomic,retain) 	IBOutlet UIImageView *imageView;
@property(nonatomic,retain) 	IBOutlet UITextView *content;
@property(nonatomic,retain) 	IBOutlet UITableView *relatedNewsView;	
@property(nonatomic,retain) 	NSMutableDictionary *news;
@property(nonatomic,retain) 	NSArray *backData;
@property(nonatomic,retain) 	NSArray *relatedNewsData;
@property(nonatomic,retain) 	IconDownloader *iconDownloader;
@property(nonatomic,assign)		float fontSize;
@property(nonatomic,assign)		BOOL isRelatedNews;

-(void)startIconDownload:(NSMutableDictionary *)newsRecord; 
-(void)loadNewsImage;
-(void)setGesture;
-(void)resizeContent;
-(void)resetFrame:(UIView*)view withY:(int)y;
-(void)setRelatedNews;
-(void)setImageViewHeight:(UIImageView*)view ByImage:(UIImage*)image;
- (void)composeTextVewBlock:(UITextView*)textView withContent:(NSString*)text andFontSize:(UIFont*)font;
-(void)saveFontSize;

// - (IBAction)moveToPreviousNews:(id)sender;
// - (IBAction)moveToNextNews:(id)sender;

@end

@protocol NewsDetailDelegate 
- (void)showDetailNews:(int)indexPath withBackData:(NSArray*)backData popPreviousView:(BOOL)pop isRelatedNews:(BOOL)isRelatedNews;
- (void)showPreviousDetailNews:(int)indexPath withBackData:(NSArray*)backData isRelatedNews:(BOOL)isRelatedNews;
- (void)showNextDetailNews:(int)indexPath withBackData:(NSArray*)backData isRelatedNews:(BOOL)isRelatedNews;
@end
