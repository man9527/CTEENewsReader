@class AppRecord;
@class RootViewController;

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject
{
    //AppRecord *appRecord;
	NSMutableDictionary *newsRecord;
    NSIndexPath *indexPathInTableView;
    id <IconDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
	
	NSString *imageType;
	NSString *savedImageType;
	
	int imageHeight;
}

//@property (nonatomic, retain) AppRecord *appRecord;
@property (nonatomic, retain) NSMutableDictionary *newsRecord;

@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <IconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

@property (nonatomic, retain) NSString *imageType;
@property (nonatomic, retain) NSString *savedImageType;

@property (nonatomic, assign) int imageHeight;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol IconDownloaderDelegate 

- (void)appImageDidLoad:(NSIndexPath *)indexPath;

@end