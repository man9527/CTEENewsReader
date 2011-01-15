//
//  UserIndustrySetting.h
//  IBENewsReader
//
//  Created by man9527 on 2010/12/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserIndustrySetting : NSObject {
	NSMutableArray *selectedIndustry;
	NSMutableArray *nonSelectedIndustry;
	NSArray *ALL_INDUSTRY_ID;
}

@property(nonatomic,retain) 	NSMutableArray *selectedIndustry;
@property(nonatomic,retain) 	NSMutableArray *nonSelectedIndustry;
@property(nonatomic,retain) 	NSArray *ALL_INDUSTRY_ID;


+(UserIndustrySetting *)sharedUserIndustrySetting;
-(void)loadSettingFromLocal;
-(NSArray*)getAllIndustryId;
-(NSArray*)getAllSelectedIndustryId;
-(NSArray*)getAllNonSelectedIndustryId;
// -(void)setSelectedIndustry:(NSString*)industryId selected:(bool)selected;
//-(void)setSelectedIndustry:(int)index selected:(bool)selected;
-(void)setSelectedIndustry:(NSString*)industryId selected:(bool)selected;
-(void)moveSelectedIndustryFrom:(int)fromIndex To:(int)toIndex;
-(bool)isSelected:(NSString*)industryId;
// -(NSString*)getKeyByIndustryId:(NSString*)industryId;

+(NSString*)getDisplayTextByIndustryId:(NSString*)industryId;
@end
