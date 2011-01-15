//
//  SettingIndustryCellView.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingIndustryCellView.h"


@implementation SettingIndustryCellView
@synthesize industryName, industryId, checkButton;

-(void)checkButtonClick:sender
{
	UserIndustrySetting *userIndustrySetting = [UserIndustrySetting sharedUserIndustrySetting];
	
	if (isSelected){
		[userIndustrySetting setSelectedIndustry:industryId selected:NO];
		[self setIsSelected:false];
	} else {
		[userIndustrySetting setSelectedIndustry:industryId selected:YES];
		[self setIsSelected:true];
	}
}

-(void)setIsSelected:(bool)selected
{
	if (selected){
		isSelected = true;
		[checkButton setSelected:YES];
	} else {
		isSelected = false;
		[checkButton setSelected:NO];
	}
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)dealloc {
	[checkButton release];
	[industryId release];
	[industryName release];

    [super dealloc];
}


@end
