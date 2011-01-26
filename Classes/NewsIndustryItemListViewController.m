//
//  NewsIndustryItemListViewController.m
//  IBENewsReader
//
//  Created by William Chu on 2011/1/4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsIndustryItemListViewController.h"
#import "SettingIndustryViewController.h"
#import "NewsIndustryContainerViewController.h"
#import "User.h"
#import "UserService.h"
#import "IBENewsReaderAppDelegate.h"

@implementation NewsIndustryItemListViewController
@synthesize userIndustrySetting, selectedIndustry, cachedControllers;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self awakeFromNib];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.cachedControllers = [NSMutableDictionary dictionary];
	self.userIndustrySetting = [UserIndustrySetting sharedUserIndustrySetting];
	self.selectedIndustry = [userIndustrySetting getAllSelectedIndustryId];
	
	UIBarButtonItem *addIndustryButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openAddIndustryView)];
	self.navigationItem.rightBarButtonItem = addIndustryButton;
	[addIndustryButton release];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	self.editButtonItem.target = self;
	self.editButtonItem.action = @selector(editButtonClicked);
	
	self.navigationController.delegate = self;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)openAddIndustryView
{
	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];

	if ( [appDelegate validateForPaidUser] ) {
		SettingIndustryViewController *settingIndustryViewController = [[SettingIndustryViewController alloc] initWithNibName:@"SettingIndustryViewController" bundle:nil];
		[self.navigationController pushViewController:settingIndustryViewController animated:YES];
		[settingIndustryViewController release];
	}
}

#pragma mark -
#pragma mark Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int nodeCount = [selectedIndustry count];
	
	if (nodeCount==0)
	{
		self.navigationItem.leftBarButtonItem = nil;
		return 1;
	}
	else 
	{
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
		return nodeCount;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    static NSString *PlaceholderCellIdentifier = @"PlaceHolder";
    
	int nodeCount = [selectedIndustry count];
	
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:PlaceholderCellIdentifier] autorelease];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
        }
		
		cell.detailTextLabel.text = @"尚未選擇偏好產業";
		
		return cell;
    }
	
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
	cell.textLabel.text =  [UserIndustrySetting getDisplayTextByIndustryId:[selectedIndustry objectAtIndex:indexPath.row]]; // = NSLocalizedString(key, nil);

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
/*
- (UITableViewCellAccessoryType) tableView: (UITableView*)tv accessoryTypeForRowWithIndexPath: (NSIndexPath*)indexPath
{
	return UITableViewCellAccessoryDisclosureIndicator;
}
*/
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
		NSString *industryId=[self.selectedIndustry objectAtIndex:indexPath.row];
		[self.userIndustrySetting setSelectedIndustry:industryId selected:false];

        if ([self.selectedIndustry count]>0)
		{
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
		else {
			[self setEditing:NO animated:YES];
			self.editing=NO;
			[self.tableView reloadData];
		}
    }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

	[self.userIndustrySetting moveSelectedIndustryFrom:fromIndexPath.row To:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if ([self.selectedIndustry count]>0 && [appDelegate validateForPaidUser] ) {
		
		NewsIndustryContainerViewController *container = [cachedControllers objectForKey:[self.selectedIndustry objectAtIndex:indexPath.row]];
		
		if (container==nil) {
			container = [[NewsIndustryContainerViewController alloc] initWithNibName:@"NewsIndustryContainerViewController" bundle:nil];
			container.requestKey=[self.selectedIndustry objectAtIndex:indexPath.row];
			NSString *keyText = [UserIndustrySetting getDisplayTextByIndustryId:container.requestKey];
			container.selfTitle = keyText;
			container.titleTemplate = [NSString stringWithFormat:@"%@ (%@/%@)", keyText, @"%i", @"%i"];
			[container autorelease];
			[cachedControllers setObject:container forKey:[self.selectedIndustry objectAtIndex:indexPath.row]];
		}
		else {
			[container viewWillAppear:NO];
		}

		[self.navigationController pushViewController:container animated:YES];
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController isKindOfClass:[NewsIndustryItemListViewController class]])
	{
		[self.tableView reloadData];
	}
	else if ([viewController isKindOfClass:[NewsIndustryContainerViewController class]])
	{
		[self.navigationController setToolbarHidden:YES animated:NO];
		[(NewsIndustryContainerViewController*)viewController loadNewsData:NO];
	}
}

- (void)editButtonClicked
{
	if (self.editing)
	{
		[self.tableView setEditing:NO animated:YES];
		self.editing = NO;		
	}
	else {
		IBENewsReaderAppDelegate *appDelegate = (IBENewsReaderAppDelegate*)[[UIApplication sharedApplication] delegate];
		if ( [appDelegate validateForPaidUser] ) {
			[self.tableView setEditing:YES animated:YES];
			self.editing = YES;
		}
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	[userIndustrySetting release];
	[selectedIndustry release];
	[cachedControllers release];
    [super dealloc];
}


@end

