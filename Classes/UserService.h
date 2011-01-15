//
//  UserService.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserService : NSObject {
}

+(User*)currentLogonUser;
+(void)setCurrentLogonUser:(User*)u;
+(void)logoutCurrentLogonUser:(User*)u;

+(void)saveUserLocal:(User*)u;
+(void)deleteUserLocal:(User*)u;
+(User*)getUserLocal;

+(void)loadCacheUserAsLogonUser;
@end
