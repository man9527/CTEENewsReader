//
//  ADViewController.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadADDelegate
- (void)didLoadAD:(BOOL)show;
@end

@interface ADViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *adView;
		
	NSString *zoneid;
	NSString *sub;
	
	id<LoadADDelegate> delegate;
}

@property (nonatomic,retain)	IBOutlet UIWebView *adView;
@property (nonatomic,assign)	id<LoadADDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil zoneid:(NSString*)zoneidparam sub:(NSString*)subparam;
- (void)reload;
- (void)loadADContent;
@end
