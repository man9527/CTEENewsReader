#import "IconDownloader.h"
#import "URLConnectionManager.h"

#define kAppIconHeight 48


@implementation IconDownloader

@synthesize newsRecord;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize imageType, imageHeight, savedImageType;

#pragma mark

- (void)dealloc
{
	[newsRecord release];
    [indexPathInTableView release];
    
    [activeDownload release];
    
	[imageType release];
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
	NSURLConnection *conn = [URLConnectionManager getURLConnectionWithURL:[newsRecord objectForKey:imageType] delegate:self];
    self.imageConnection = conn;
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    NSLog(@"image size %d", image.size.width);
    
	if (image.size.width > self.imageHeight) // && image.size.height != self.imageHeight)
	{
		int h = (float)image.size.height / (float)(image.size.width / self.imageHeight); // * image.size.height;
        CGSize itemSize = CGSizeMake(self.imageHeight, h); //self.imageHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, h);
		[image drawInRect:imageRect];
		// self.appRecord.appIcon = UIGraphicsGetImageFromCurrentImageContext();
		[self.newsRecord setObject:UIGraphicsGetImageFromCurrentImageContext() forKey:savedImageType];
		UIGraphicsEndImageContext();
    }
    else
    {
        // self.appRecord.appIcon = image;
		[self.newsRecord setObject:image forKey:savedImageType];
    }
    
    self.activeDownload = nil;
    [image release];
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
        
    // call our delegate and tell it that our icon is ready for display
	if(delegate!=nil)
	{
		[delegate appImageDidLoad:self.indexPathInTableView];
	}
}

@end

