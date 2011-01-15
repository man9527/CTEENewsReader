//
//  User.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : NSObject {
	NSString *username;
	NSString *password;
	NSString *authkey;
	NSDate *expireDate;
	NSDateFormatter *dateformatterForInput; 
	NSDateFormatter *dateformatterForOutput; 
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *authkey;
@property (nonatomic, retain) NSDate *expireDate;

-(bool)isPaid;
-(void)setExpireDateByString:(NSString *)dateString;
-(NSString*)getExpireDateByString;

@end
