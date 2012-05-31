//
//  RootViewController.m
//  UAVController
//
//  Created by Ning Lu on 10-7-29.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "Controller.h"
#import "UAVControllerAppDelegate.h"

@implementation RootViewController


#pragma mark -
#pragma mark Instance Methods

 
#pragma mark - 
#pragma mark Control Actions


//This method is that press "Control" button in the Welcome Screen to go to the Controlling Screen.
-(IBAction)goToMainController:(id)sender{
	
	Controller *controllerView=[[Controller alloc] initWithNibName:@"Controller" bundle:[NSBundle mainBundle]];
	
	UAVControllerAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
	if ([delegate.navigationController isEqual:nil]) {
		return;
	}
	controllerView.title=@"Controller";
	
	[delegate.navigationController pushViewController:controllerView animated:YES];
	[controllerView release];
	 
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
     self.title=@"Welcome";
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

