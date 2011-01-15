//
//  UILoginFailDelegate.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UILoginFailDelegate : NSObject <UIAlertViewDelegate> {
	NSDictionary *param;
}

@property (nonatomic,retain) NSDictionary *param;
@end
