//
//  Controller.m
//  UAVController
//
//  Created by Ning Lu on 10-7-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "TextAlertView.h"
#import "Communicator.h"
#import "PIDController.h"

@implementation Controller



@synthesize longPressRecognizer,rotationRecognizer;

#pragma mark -
#pragma mark Private Methods


// Event Method for "Start" button.
-(void)startControlling
{
	if ([communicator buildConnection]) {
		UIBarButtonItem *endButton=[[UIBarButtonItem alloc] initWithTitle:@"End" 
																	style:UIBarButtonItemStyleDone target:self action:@selector(endControlling)];
		self.navigationItem.rightBarButtonItem=endButton;
		[endButton release];
		
	}
}

//Event Method for "End" button
-(void)endControlling
{		
	if (controller.uav_State!=Ground) {
		UIAlertView *statusAlertView=[[UIAlertView alloc] initWithTitle:@"Warning!"
																message:@"You cannot close connection while UAV is not on the Ground" 
															   delegate:self 
													          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[statusAlertView show];
		[statusAlertView release];
		return;
	}
	if (![communicator killConnection]) {
		UIBarButtonItem *startButton=[[UIBarButtonItem alloc] initWithTitle:@"Start" 
																	  style:UIBarButtonItemStylePlain target:self action:@selector(startControlling)];
		self.navigationItem.rightBarButtonItem=startButton;
		[startButton release];
		
	}
	
		
	
}


-(void)GUIUpdata
{
	if (!communicator.isClientConeected) {
		UIImageView *statusImage=(UIImageView *)[self.view viewWithTag:123];
		NSString *imagePath;
		imagePath=[[NSBundle mainBundle] pathForResource:@"red" ofType:@"ico"];
		UIImage *redLED=[[UIImage alloc] initWithContentsOfFile:imagePath];
		statusImage.image=redLED;
		[redLED release];
	}else {
		UIImageView *statusImage=(UIImageView *)[self.view viewWithTag:123];
		NSString *imagePath;
		imagePath=[[NSBundle mainBundle] pathForResource:@"green" ofType:@"ico"];
		UIImage *redLED=[[UIImage alloc] initWithContentsOfFile:imagePath];
		statusImage.image=redLED;
		[redLED release];
	}
	
	UILabel *stateLabel=(UILabel *)[self.view viewWithTag:124];
	
	switch (controller.uav_State) {
		case Ground:
			stateLabel.text=@"Ground!";
			break;
		case TakingOff:
			stateLabel.text=@"Taking Off!";
			break;
		case Standby:
			stateLabel.text=@"Standing By!";
			break;
		case Landing:
			stateLabel.text=@"Landing!";
			break;
		default:
			break;
	}

}

// Attach Gesture Recognizers to the "Controlling" View
-(void)attachGestureRecognizer
{
	
    UISwipeGestureRecognizer *recog;
	
	
	
	//Attach Swipe Recognizer

	recog=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
	recog.direction=UISwipeGestureRecognizerDirectionUp;
	[self.view addGestureRecognizer:recog];
	[recog release];
	
	recog=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
	recog.direction=UISwipeGestureRecognizerDirectionDown;
	[self.view addGestureRecognizer:recog];
	[recog release];
	
	recog=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
	recog.direction=UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:recog];
	[recog release];
	
	recog=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
	recog.direction=UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:recog];
	[recog release];	 
	
	UIGestureRecognizer *recognizer;
	//Attach Long Press Recognizer
	recognizer=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
	[self.view addGestureRecognizer:recognizer];
	self.longPressRecognizer=(UILongPressGestureRecognizer *)recognizer;
	[recognizer release];
	
	//Attach Rotation Recognizer
	recognizer=[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(hanleRotationGesture:)];
	[self.view addGestureRecognizer:recognizer];
	self.rotationRecognizer=(UIRotationGestureRecognizer *)recognizer;
	[recognizer release];
}

// Private Method for playing sound.
-(void)wavSoundPlayBack:(NSString *)filename
{
	NSString *soundFilePath;
	NSURL *fileURL;
	AVAudioPlayer *newPlayer;
	
	soundFilePath =
	[[NSBundle mainBundle] pathForResource: filename
									ofType: @"wav"];
	
	fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
	
	newPlayer =
	[[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
										   error: nil];
	[soundFilePath release];
	[fileURL release];
	
	[newPlayer play];
	
}

#pragma mark -
#pragma mark Gesture Handlers


//handle Swipe Gesture

-(void)handleSwipeGesture:(UISwipeGestureRecognizer *)recognizer
{
	switch (recognizer.direction) {
		case UISwipeGestureRecognizerDirectionUp:
		{
			if (controller.uav_State==Standby) {
				controller.operationCode=forwardOP;
				
				if ((controller.standByPos0+300)>1100) {
					controller.standByPos0=1100;
				}
				
				controller.standByPos0+=300;
			}
			[self wavSoundPlayBack:@"forwards"];
		}
			
			break;
		case UISwipeGestureRecognizerDirectionDown:
		{
			if (controller.uav_State==Standby) {
				controller.operationCode=backwardOP;
				if ((controller.standByPos0-300)<-800) {
					controller.standByPos0=-800;
				}
				controller.standByPos0-=300;
			}
			
			[self wavSoundPlayBack:@"backwards"];
		}
			break;
		case UISwipeGestureRecognizerDirectionRight:
		{
			if (controller.uav_State==Standby) {
				controller.operationCode=rightOP;
				if ((controller.standByPos1-300)<-1100) {
					controller.standByPos1=-1100;
				}
				controller.standByPos1-=300;
			}
			[self wavSoundPlayBack:@"turn right"];
		}
			break;
		case UISwipeGestureRecognizerDirectionLeft:
		{
			if (controller.uav_State==Standby) {
				controller.operationCode=leftOP;
				if ((controller.standByPos1+300)>1300) {
					controller.standByPos1=1300;
				}
				controller.standByPos1+=300;
			}
			[self wavSoundPlayBack:@"turn left"];
		}
			break;
	}
}

//handle long press gesture

-(void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer
{
	
      if ([recognizer state]==UIGestureRecognizerStateEnded) {
		  UIAlertView *statusAlertView=[[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take Off",@"Landing",nil];
		  statusAlertView.tag=1;
		  [statusAlertView show];
		  [statusAlertView release];
	  }
}

//handle rotation gesture

-(void)hanleRotationGesture:(UIRotationGestureRecognizer *)recognizer
{
	//clockwise rotation then goes down, otherwise goes up
	if([recognizer state]==UIGestureRecognizerStateEnded)
	{
		CGFloat rotated=[recognizer rotation];
		if (rotated>0) {
			
			if (controller.uav_State==Standby) {
				controller.operationCode=downOP;

				if((controller.standByPos2-150)<300)
				{
					controller.standByPos2=300;
				}
				controller.standByPos2-=100;
			}
			
			[self wavSoundPlayBack:@"down"];
		}else {
			if (controller.uav_State==Standby) {
				controller.operationCode=upOP;
				if((controller.standByPos2+150)>1000)
				{
					controller.standByPos2=1000;
				}
				controller.standByPos2+=100;
			}
			[self wavSoundPlayBack:@"up"];
		}
		
	}	
}

#pragma mark -
#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	switch ([alertView tag]) {
		case 1:
		{
			//Long press alert view.
			if (buttonIndex==1) {
				
				controller.uav_State=TakingOff;
				controller.takeOffPos0=controller.x_position;
				controller.takeOffPos1=controller.y_position;
				controller.takeOffPos2=controller.z_position;
				
				
			}else {
				if (buttonIndex==2) {
					
					controller.uav_State=Landing;
				}
			}
		}
			break;
		case 2:
			break;
	}
	
}


#pragma mark -
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	return NO;
}



#pragma mark -
#pragma mark Lifecycle Methods
/* 
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibNameOrNil])) {
        // Custom initialization
    }
    return self;
}

*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	//add a custom right button
	if (self.navigationItem.rightBarButtonItem==nil) {
		UIBarButtonItem *startButton=[[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startControlling)];
		self.navigationItem.rightBarButtonItem=startButton;
		[startButton release];
	}
	
	[self attachGestureRecognizer];
	
	communicator=[Communicator sharedCommunicator];
	controller=[PIDController SharedPIDController];
	
	[NSTimer  scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(GUIUpdata) userInfo:nil repeats:YES];

}


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
	communicator=nil;

}


- (void)dealloc {	
	[rotationRecognizer release];
	[longPressRecognizer release];
    [super dealloc];
}


@end
