//
//  ADViewController.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ADViewController : UIViewController {
	IBOutlet UIWebView *adView;
	NSString *adpath;
}

@property (nonatomic,retain)	IBOutlet UIWebView *adView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil adpath:(NSString*)path;

@end
