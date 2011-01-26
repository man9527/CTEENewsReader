//
//  NewsListFooterViewController.h
//  IBENewsReader
//
//  Created by William Chu on 2010/12/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewsReloadDelegate;

@interface NewsListFooterViewController : UIViewController {
	IBOutlet UIButton *dateLabel;
	IBOutlet UIButton *reloadLabel;
	id<NewsReloadDelegate> delegate;
}

@property (nonatomic,assign) id<NewsReloadDelegate> delegate;
@property(nonatomic,retain) IBOutlet UIButton *dateLabel;
@property(nonatomic,retain) IBOutlet UIButton *reloadLabel;

-(IBAction)forceReload:sender;

@end


@protocol NewsReloadDelegate 
- (void)loadNewsData:(bool)forceReload;
- (void)reloadAD;
@end
