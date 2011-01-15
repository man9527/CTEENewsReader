//
//  CacheManager.h
//  IBENewsReader
//
//  Created by William Chu on 2010/12/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CacheManager : NSObject {

}

+ (void)cacheImage:(UIImage*)image withName:(NSString *) ImageURLString;
+ (UIImage *) getCachedImage: (NSString *) imageURLString;
+ (void) cacheData: (NSDictionary *)data withType:(NSString*)type;
+ (NSMutableDictionary*) getCachedData: (NSString *) type;

+ (NSString*)getCacheImageDirectory;
+ (NSString*)getUniquePath:(NSString*)imageURL;
@end
