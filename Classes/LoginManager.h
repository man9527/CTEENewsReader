//
//  LoginManager.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@protocol DidLoginDelegate
@optional
- (bool)checkInput;
@required
- (void)didLoginResult:(bool) isSuccessful andReason:(NSString*)reason For:(User*) u;
@end

@interface LoginManager : NSObject {
	id<DidLoginDelegate> delegate;
	NSURLConnection	*loginConnection;
	NSMutableData *loginResultData;

	@private
		User *user;
}

@property (nonatomic,assign) id<DidLoginDelegate> delegate;
@property (nonatomic,retain) NSURLConnection	*loginConnection;
@property (nonatomic,retain) NSMutableData *loginResultData;
@property (nonatomic,retain) User *user;

-(void)login:(User*) u;
-(void)logout:(User*) u;
@end
