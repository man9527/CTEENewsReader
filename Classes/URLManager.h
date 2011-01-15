//
//  URLManager.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface URLManager : NSObject {

}

+(NSString*) getRegisterURL;
+(NSString*) getForgetPasswordURL;
+(NSString*) getSubscribeURL;
+(NSString*) getLoginURLForUser:(User*)u;
+(NSString*) getAddPayURLForUser:(User*)u withPayCode:(NSString*)paycode;
+(NSString*) getSelectNewsURLForUser:(User*)u;
+(NSString*) getHeadNewsURLForUser:(User*)u;
+(NSString*) getNewsByPlateURLForUser:(User*)u withPlate:(NSString*)plate;
+(NSString*) getNewsByIndustryURLForUser:(User*)u withIndustry:(NSString*)industry;


@end
