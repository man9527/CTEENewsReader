//
//  UIAddPayFailDelegate.h
//  IBENewsReader
//
//  Created by William Chu on 2010/12/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIAddPayFailDelegate : NSObject  <UIAlertViewDelegate> {
	NSDictionary *param;
}
@property (nonatomic,retain) NSDictionary *param;

@end
