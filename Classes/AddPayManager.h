//
//  AddPayManager.h
//  IBENewsReader
//
//  Created by William Chu on 2010/12/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@protocol DidAddPayDelegate
- (void)didAddPayResult:(int) status andReason:(NSString*)reason For:(User*) u;
- (bool)checkInput;
@end

@interface AddPayManager : NSObject {
	id<DidAddPayDelegate> delegate;
	NSURLConnection	*addPayConnection;
	NSMutableData *addPayResultData;
	
	@private
		User *user;
}

@property (nonatomic,assign) id<DidAddPayDelegate> delegate;
@property (nonatomic,retain) NSURLConnection	*addPayConnection;
@property (nonatomic,retain) NSMutableData *addPayResultData;
@property (nonatomic,retain) User *user;

-(void)addPay:(User*) u withPayCode:(NSString*)paycode;

@end
