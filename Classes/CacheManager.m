//
//  CacheManager.m
//  IBENewsReader
//
//  Created by William Chu on 2010/12/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CacheManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "JSON.h"

@implementation CacheManager

+(NSString*)getCacheImageDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [paths objectAtIndex:0];

	BOOL isDir = NO;
	NSError *error;

	if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
		[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
	}
		
	return cachePath;
}

+ (void)cacheImage:(UIImage*)image withName:(NSString *) imageURLString
{
    // Generate a unique path to a resource representing the image you want
    NSString *uniquePath = [self getUniquePath:imageURLString];
	
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if([imageURLString rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [imageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound || 
                [imageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
    }
	
	NSLog(@"cache image done");
}

+ (UIImage *) getCachedImage: (NSString *) imageURLString
{
	NSLog(@"url:%@",imageURLString);
    NSString *uniquePath = [self getUniquePath:imageURLString];
    
    UIImage *image=nil;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
		NSLog(@"get image ok");
    }
	
	NSLog(@"get image done");

    return image;
}

+ (void) cacheData: (NSDictionary *)data withType:(NSString*)type
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];

	
	NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.txt", type]];


	NSString *jsonStr = [data JSONRepresentation];
	NSLog(@"write path: %@",filePath);
	
	// overwrite anyway
	if ( [jsonStr writeToFile:filePath atomically: YES encoding:NSUnicodeStringEncoding error:NULL] )
		NSLog(@"writw to file ok");
	else {
		NSLog(@"write to file fail");
	}

}

+ (NSMutableDictionary*) getCachedData: (NSString *) type
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.txt", type]];

	NSLog(@"read path: %@",filePath);

	NSString *jsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:NULL];
	
	if (jsonStr)
	{
		NSMutableDictionary *result = [jsonStr JSONValue];
		//[jsonStr release];
				
		return result;
	}
	else {
		return nil;
	}

	// NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];	
	// return plistDict;
}

+(NSString*)getUniquePath:(NSString *)imageURL
{
	const char* str = [imageURL UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
	
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
	
    NSString *uniquePath = [[self getCacheImageDirectory] stringByAppendingPathComponent: ret];
	
    return uniquePath;
}


@end
