//
//  NewsBoardViewController.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewsBoardViewController : UIViewController<UIWebViewDelegate> {
	IBOutlet UIWebView *aboutText;
}

@property (nonatomic,retain) 	IBOutlet UIWebView *aboutText;

@end
