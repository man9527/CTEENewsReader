//
//  URLConnectionManager.h
//  IBENewsReader
//
//  Created by William Chu on 2011/1/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLConnectionManager : NSObject {

}

+ (NSURLConnection*) getURLConnectionWithURL:(NSString*) urlString delegate:(id)delegate;
@end
