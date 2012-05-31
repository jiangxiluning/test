//
//  PIDController.h
//  UAVController
//
//  Created by Ning Lu on 10-8-5.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark GlobleVariable
typedef enum  {
	Ground,Landing,TakingOff,Standby
}UAVState;

typedef enum {
	forwardOP=1,rightOP,backwardOP,leftOP,downOP,upOP
}OPerationCode;


@interface PIDController : NSObject {
	double x_position;
	double y_position;
	double z_position;
	double x_angle;
	double y_angle;
	double z_angle;
	
	Byte throlltleValue;
	Byte pitchValue;
	Byte rollValue;
	Byte yawValue;
	
	int uav_State;
	int operationCode;
	
	double takeOffPos0;
	double takeOffPos1;
	double takeOffPos2;
	
	double standByPos0;
	double standByPos1;
	double standByPos2;

}

@property(assign,nonatomic) double x_position;
@property(assign,nonatomic) double y_position;
@property(assign,nonatomic) double z_position;
@property(assign,nonatomic) double x_angle;
@property(assign,nonatomic) double y_angle;
@property(assign,nonatomic) double z_angle;
@property(assign,nonatomic) Byte throlltleValue;
@property(assign,nonatomic) Byte pitchValue;
@property(assign,nonatomic) Byte rollValue;
@property(assign,nonatomic) Byte yawValue;
@property(assign,nonatomic) int uav_State;
@property(assign,nonatomic) int operationCode;
@property(assign,nonatomic) double takeOffPos0;
@property(assign,nonatomic) double takeOffPos1;
@property(assign,nonatomic) double takeOffPos2;
@property(assign,nonatomic) double standByPos0;
@property(assign,nonatomic) double standByPos1;
@property(assign,nonatomic) double standByPos2;



+(PIDController *)SharedPIDController;
-(void)TaskManager;

@end
