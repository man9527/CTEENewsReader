//
//  URLManager.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "URLManager.h"

static NSString *const RegisterURL=@"https://d9.ctee.com.tw/m/addmember.aspx"; // 會員註冊
static NSString *const ForgetPasswordURL=@"https://d9.ctee.com.tw/m/passwordrecovery.aspx"; // Forget password
static NSString *const SubscribeURL=@"https://d9.ctee.com.tw/m/order"; // 前往訂閱
static NSString *const ManualURL=@"http://d9.ctee.com.tw/m/OperationManual.pdf";  // 手冊
static NSString *const LoginURL=@"https://d9.ctee.com.tw/m/checkmember.aspx?username=%@&password=%@"; // 會員登入
static NSString *const AddPayURL=@"http://d9.ctee.com.tw/m/addpayhistory.aspx?username=%@&password=%@&prememberkey=%@"; // 會員儲值
static NSString *const ModifyDataURL=@"https://d9.ctee.com.tw/m/profile.aspx?username=%@&password=%@"; // 修改會員資料
static NSString *const SelectNewsURL=@"https://d9.ctee.com.tw/m/selectnews.aspx?";  // 精選新聞
static NSString *const HeadNewsURL=@"https://d9.ctee.com.tw/m/headnewsbyplate.aspx?"; // 各版頭條
static NSString *const NewsByPlateURL=@"https://d9.ctee.com.tw/m/newsbyplate.aspx?plate=%@&";  // 各版新聞
static NSString *const NewsByIndustryURL=@"https://d9.ctee.com.tw/m/newsbyindustry.aspx?industry=%@&";  // 產業新聞
static NSString *const adURL=@"https://d9.ctee.com.tw/m/adscode.aspx?zone=%@&sub=%@";  // 廣告

static NSString *const NewsParameter=@"username=%@&authkey=%@";

@implementation URLManager

+(NSString*) getRegisterURL
{
	return RegisterURL;
}

+(NSString*) getForgetPasswordURL
{
	return ForgetPasswordURL;
}

+(NSString*) getSubscribeURL
{
	return SubscribeURL;
}

+(NSString*) getAdURL
{
	return adURL;
}

+(NSString*) getManualURL
{
	return ManualURL;
}

+(NSString*) getLoginURLForUser:(User*)u
{
	if (u!=nil) {
		return [NSString stringWithFormat:LoginURL, u.username, u.password];
	}
	else {
		return [NSString stringWithFormat:LoginURL, @"", @""];
	}
}

+(NSString*) getModifyDataURLForUser:(User*)u
{
	// NSString *loginStr = [DataEncryptor encrypt:[NSString stringWithFormat:LoginParameter, u.username, u.password]];
	if (u!=nil) {
		return [NSString stringWithFormat:ModifyDataURL, u.username, u.password];
	}
	else {
		return ModifyDataURL;
	}
	
}

+(NSString*) getAddPayURLForUser:(User*)u withPayCode:(NSString*)paycode
{
	// NSString *addPayStr = [DataEncryptor encrypt:[NSString stringWithFormat:AddPayParameter, u.username, u.password, paycode]];
	if (u!=nil){
		return [NSString stringWithFormat:AddPayURL, u.username, u.password, paycode];
	}else {
		return AddPayURL;
	}

}

+(NSString*) getSelectNewsURLForUser:(User*)u
{
	//NSString *selectNewsStr = [DataEncryptor encrypt:[NSString stringWithFormat:NewsParameter, u.username, u.authkey]];
	//return [NSString stringWithFormat:SelectNewsURL, selectNewsStr];
	if (u!=nil){
		NSString *param = [NSString stringWithFormat:NewsParameter, u.username, u.authkey];
		NSString *url = [SelectNewsURL stringByAppendingString:param];
		return url;
		// return [NSString stringWithFormat:SelectNewsURL, u.username, u.authkey];
	}else {
		return SelectNewsURL;
	}	
}

+(NSString*) getHeadNewsURLForUser:(User*)u
{
	//NSString *headNewsStr = [DataEncryptor encrypt:[NSString stringWithFormat:NewsParameter, u.username, u.authkey]];
	//return [NSString stringWithFormat:HeadNewsURL, headNewsStr];
	if (u!=nil){
		NSString *param = [NSString stringWithFormat:NewsParameter, u.username, u.authkey];
		NSString *url = [HeadNewsURL stringByAppendingString:param];
		return url;
		
		// return [NSString stringWithFormat:HeadNewsURL, u.username, u.authkey];
	}else {
		return HeadNewsURL;
	}		
}

+(NSString*) getNewsByPlateURLForUser:(User*)u withPlate:(NSString*)plate
{
	//NSString *plateNewsStr = [DataEncryptor encrypt:[NSString stringWithFormat:NewsParameter, u.username, u.authkey]];
	//return [NSString stringWithFormat:NewsByPlateURL, plateNewsStr];
	if (u!=nil){
		NSLog(@"user name: %@", u.username);
		NSLog(@"user name: %@", u.password);
		NSString *param = [NSString stringWithFormat:NewsParameter, u.username, u.authkey];
		NSString *url = [[NSString stringWithFormat:NewsByPlateURL, [plate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] stringByAppendingString:param];
		return url;
		
		//return [NSString stringWithFormat:NewsByPlateURL, u.username, u.authkey, plate];
	}else {
		return [NSString stringWithFormat:NewsByPlateURL, plate];
	}		
}

+(NSString*) getNewsByIndustryURLForUser:(User*)u withIndustry:(NSString*)industry
{
	//NSString *industryNewsStr = [DataEncryptor encrypt:[NSString stringWithFormat:NewsParameter, u.username, u.authkey]];
	//return [NSString stringWithFormat:NewsByIndustryURL, industryNewsStr];
	if (u!=nil){
		NSString *param = [NSString stringWithFormat:NewsParameter, u.username, u.authkey];
		NSString *url = [[NSString stringWithFormat:NewsByIndustryURL, [industry stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] stringByAppendingString:param];
		return url;
		
		//return [NSString stringWithFormat:NewsByPlateURL, u.username, u.authkey, plate];
	}else {
		return [NSString stringWithFormat:NewsByIndustryURL, industry];
	}		
	
}



@end
