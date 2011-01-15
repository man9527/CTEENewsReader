//
//  UserPassRepository.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserPassRepository : NSObject {

}

+(User*)getUser;
+(void)setUser:(User*) u;
+(void)deleteUser:(User*) u;
@end
