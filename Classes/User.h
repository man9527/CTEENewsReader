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
	NSDate *invalidDate;
	float fontSize;

	NSDateFormatter *dateformatterForInput; 
	NSDateFormatter *dateformatterForOutput; 
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *authkey;
@property (nonatomic, retain) NSDate *expireDate;
@property (nonatomic, retain) NSDate *invalidDate;
@property (nonatomic, assign) float fontSize;

-(bool)isPaid;
-(void)setExpireDateByString:(NSString *)dateString;
-(NSString*)getExpireDateByString;
-(void)setInvalidDateByString:(NSString *)dateString;
-(NSString*)getInvalidDateByString;

@end
