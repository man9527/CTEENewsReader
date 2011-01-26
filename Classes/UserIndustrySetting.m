//
//  UserIndustrySetting.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserIndustrySetting.h"

static NSString *const PREFIX=@"INDUSTRY";
static UserIndustrySetting *userIndustrySetting;

@implementation UserIndustrySetting
@synthesize nonSelectedIndustry,selectedIndustry,ALL_INDUSTRY_ID;
#pragma mark Singleton Methods
+(UserIndustrySetting *)sharedUserIndustrySetting
{
	@synchronized(self)	        
	{
		if (!userIndustrySetting) {
			userIndustrySetting = [[super allocWithZone:NULL] init];
		}
		
	}
	return userIndustrySetting;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedUserIndustrySetting] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (void)release {
    // never release
}
- (id)autorelease {
    return self;
}

-(id)init
{
	if (self = [super init]) {
		NSString *path = [[NSBundle mainBundle] pathForResource:
						 @"IndustryList" ofType:@"plist"];
		
		// Build the array from the plist  
		self.ALL_INDUSTRY_ID = [[NSArray alloc] initWithContentsOfFile:path];
		
		//self.ALL_INDUSTRY_ID = [[NSArray alloc] initWithObjects:
		//				   @"01",@"02",@"03",@"04",@"05",@"06",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",
		//				   @"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",
		//				   @"31",nil];
		
		[self loadSettingFromLocal];
	}
	return self;
}

-(void)loadSettingFromLocal
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

	// release old data if already exist
	if (selectedIndustry!=nil)
	{
		[selectedIndustry release];
	}
	if (nonSelectedIndustry!=nil)
	{
		[nonSelectedIndustry release];
	}
	
	self.selectedIndustry = [prefs objectForKey:@"selectedIndustry"];

	if (self.selectedIndustry==nil)
	{
		self.selectedIndustry = [[NSMutableArray alloc] init];
	}
	else {
		// need to verify if the industry still exists
		for (NSString *industryId in self.selectedIndustry) {
			if ([ALL_INDUSTRY_ID indexOfObject:industryId]==NSNotFound)
			{
				[self.selectedIndustry removeObject: industryId];
			}		
		}
	}

	self.nonSelectedIndustry = [[NSMutableArray alloc] init];

	for (NSString *industryId in ALL_INDUSTRY_ID) {
		if ([self.selectedIndustry indexOfObject:industryId]==NSNotFound)
		{
			[self.nonSelectedIndustry addObject:industryId];
		}		
	}
}

-(NSArray *)getAllIndustryId
{
	return ALL_INDUSTRY_ID;
}

-(NSArray*)getAllSelectedIndustryId
{
	return self.selectedIndustry;
	// return [[NSArray alloc] initWithArray:self.selectedIndustry copyItems:YES];
}

-(NSArray*)getAllNonSelectedIndustryId
{
	return self.nonSelectedIndustry;
	//return [[NSArray alloc] initWithArray:self.nonSelectedIndustry copyItems:YES];
}
-(void)setSelectedIndustry:(NSString*)industryId selected:(bool)selected
{
	if (selected)
	{
		[self.selectedIndustry addObject:industryId];
		[self.nonSelectedIndustry removeObject:industryId];
	}
	else {
		[self.nonSelectedIndustry addObject:industryId];
		[self.selectedIndustry removeObject:industryId];
	}
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:self.selectedIndustry forKey:@"selectedIndustry"];
	[prefs setObject:self.nonSelectedIndustry forKey:@"nonSelectedIndustry"];	
}

-(void)moveSelectedIndustryFrom:(int)fromIndex To:(int)toIndex
{
	if (fromIndex < toIndex)
	{
		NSString *item = [self.selectedIndustry objectAtIndex:fromIndex];
		NSLog(@"move item %@",item);
		[self.selectedIndustry insertObject:item atIndex:toIndex+1];

		NSLog(@"insert item %@",item);
		for (NSString *s in self.selectedIndustry)
		{
			NSLog(@"selected: %@",s);
		}
		
		[self.selectedIndustry removeObjectAtIndex:fromIndex];
		NSLog(@"delete item %@",item);
		for (NSString *s in self.selectedIndustry)
		{
			NSLog(@"selected: %@",s);
		}
		
	}
	else {
		NSString *item = [self.selectedIndustry objectAtIndex:fromIndex];
		[self.selectedIndustry insertObject:item atIndex:toIndex];
		[self.selectedIndustry removeObjectAtIndex:(fromIndex+1)];
	}

	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:self.selectedIndustry forKey:@"selectedIndustry"];
}


-(bool)isSelected:(NSString*)industryId
{
	if ([self.selectedIndustry indexOfObject:industryId]==NSNotFound)
	{
		return false;
	}
	else {
		return true;
	}
}

+(NSString*)getDisplayTextByIndustryId:(NSString*)industryId
{
	NSString *key = [NSString stringWithFormat:@"INDUSTRY%@",industryId];
	// NSString *text = 	// [text autorelease];
	return NSLocalizedString(key, nil);
}

- (void)dealloc {
	[selectedIndustry release];
	[nonSelectedIndustry release];
	[ALL_INDUSTRY_ID release];
	
    [super dealloc];
}

@end


