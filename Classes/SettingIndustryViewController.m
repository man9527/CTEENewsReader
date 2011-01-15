//
//  SettingIndustryViewController.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingIndustryViewController.h"
#import "UserIndustrySetting.h"
#import "SettingIndustryCellView.h"
#import "ADViewController.h"
@implementation SettingIndustryViewController

@synthesize userIndustrySetting, nonSelectedIndustry, selectedIndustry;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"選擇產業";
	self.userIndustrySetting = [UserIndustrySetting sharedUserIndustrySetting];
	self.selectedIndustry = [self.userIndustrySetting getAllSelectedIndustryId];
	self.nonSelectedIndustry = [[[NSArray alloc] initWithArray:[self.userIndustrySetting getAllNonSelectedIndustryId] copyItems:YES] autorelease];
}

// called by the table view to get the number of rows in a given section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
	return self.nonSelectedIndustry.count; // return one row for each slideshow
} // end method tableView:numberOfRowsInSection:

// called by the table view to get the cells it needs to populate itself
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// create cell identifier
	static NSString *CellIdentifier = @"SettingIndustryCellView";
	
	// get a reusable cell
	SettingIndustryCellView *cell = (SettingIndustryCellView *)[tableView
											dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// if no reusable cells are available
	if (cell == nil)
	{
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SettingIndustryCellView" owner:self options:nil];
		
		for (id currentObject in topLevelObjects){
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell =  (SettingIndustryCellView *) currentObject;
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

				break;
			}
		}
	} // end if

	NSString *industryId = [self.nonSelectedIndustry objectAtIndex:indexPath.row];
	cell.industryId = industryId;
	cell.industryName.text =  [UserIndustrySetting getDisplayTextByIndustryId:industryId]; // = NSLocalizedString(key, nil);
	
	[cell setIsSelected:[self.userIndustrySetting isSelected:industryId]];

	return cell; // return the configured cell to the table view
} // end method tableView:cellForRowAtIndexPath:

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[selectedIndustry release];
	[userIndustrySetting release];
	[nonSelectedIndustry release];

	[super dealloc];
}

@end
