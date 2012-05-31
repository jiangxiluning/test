//
//  Controller.h
//  UAVController
//
//  Created by Ning Lu on 10-7-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Communicator;
@class PIDController;


@interface Controller : UIViewController<UIAlertViewDelegate,UITextFieldDelegate>{

	UILongPressGestureRecognizer *longPressRecognizer;
	UIRotationGestureRecognizer	*rotationRecognizer;
	Communicator *communicator;
	PIDController *controller;
}

@property (nonatomic,retain) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic,retain) UIRotationGestureRecognizer *rotationRecognizer;


@end
