//
//  PIDController.m
//  UAVController
//
//  Created by Ning Lu on 10-8-5.
//  Translated from Bowen's version
//

#import "PIDController.h"



@implementation PIDController


static PIDController *_sharedPIDController;

#pragma mark PIDController




static double distanceError=0;
static int accurateRadius=300;
static BOOL controllFlag=FALSE;

static BOOL landingReady=FALSE;
static double targetPosition[3];
static int cutThrolltleHeight=100;

/* aX Roll    phi
 * aY Pitch   theta
 * aZ Yaw     psi
 */
static double aX,aY,aZ;
static double phi,theta,psi;

#pragma mark -
#pragma mark PID Controller Parameters
static int x_output;
static int y_output;
static int z_output;

static double x_velocity;
static double y_velocity;
static double z_velocity;

static double x_previousPosition;
static double y_previousPosition;
static double z_previousPosition;

static double x_error=0;
static double x_velocityError=0;
static double x_integral_velocityError=0;
static double x_derivative_velocityError=0;
static double x_previous_velocityError=0;

static double y_error=0;
static double y_velocityError=0;
static double y_integral_velocityError=0;
static double y_derivative_velocityError=0;
static double y_previous_velocityError=0;

static double z_error=0;
//static double z_velocityError=0;
static double z_integral_error=0;
static double z_derivative_error=0;
static double z_previous_error=0;

#pragma mark -
#pragma mark angles

static double yawAngle=0;
static double yaw_output=0;
static double rollAngle=0;
static double roll_output=0;
static double pitchAngle=0;
static double pitch_output=0;
static double targetRollAngle=0;
static double targetPitchAngle=0;

static double roll_error=0;
static double pitch_error=0;
static double yaw_error=0;
static double yaw_integral_error=0;


@synthesize x_position,y_position,z_position,x_angle,y_angle,z_angle;
@synthesize throlltleValue,pitchValue,rollValue,yawValue;
@synthesize uav_State,operationCode;
@synthesize takeOffPos0,takeOffPos1,takeOffPos2,standByPos0,standByPos1,standByPos2;
+(PIDController *)SharedPIDController
{
	if (!_sharedPIDController) {
		_sharedPIDController=[[PIDController alloc] init];
	}
	return _sharedPIDController;
}

-(id)init
{
	if (self=[super init]) {
		x_position=0;y_position=0;z_position=0;x_angle=0;y_angle=0;z_angle=0;
		throlltleValue=0x01;pitchValue=0x80;rollValue=0x80;yawValue=0x80;
		uav_State=Ground;operationCode=0;
		takeOffPos0=0;takeOffPos1=0;takeOffPos2=0;
		standByPos2=500;
		
	}
	return self;
}

#pragma mark -
#pragma mark Instance Methods


-(void)stateSwitcher
{
	distanceError=sqrt(x_error*x_error+y_error*y_error+z_error*z_error);
	if (distanceError<accurateRadius) {
		controllFlag=TRUE;
	}else {
		controllFlag=FALSE;
	}
	
	if ((uav_State==TakingOff)&&controllFlag) {
		uav_State=Standby;
	}
	

	
}

-(void)angleConversion
{
	/* angle conversion*/
	double len,tmp;
	double q[4]={0.0f,0.0f,0.0f,0.0f};
	
	len=sqrt(aX*aX+aY*aY+aZ*aZ);
	
	q[3]=cos(len/2.0);
	tmp=sin(len/2.0);
	if (len<1e-10) {
		q[0]=aX;
		q[1]=aY;
		q[2]=aZ;
	}
	else {
		q[0]=aX*tmp/len;
		q[1]=aY*tmp/len;
		q[2]=aZ*tmp/len;
	}
	
	//convert angle-axis to ratation matrix
	
	double	c,s,x,y=0,z;
	double dcm[3][3]={
		{0,0,0},
		{0,0,0},
        {0,0,0}};
	
	if (len<1e-15) {
		dcm[0][0]=dcm[1][1]=dcm[2][2]=1.0;
		dcm[0][1]=dcm[0][2]=dcm[1][0]=dcm[1][2]=dcm[2][0]=dcm[2][1]=0.0;
	}
	else {
		x=aX/len;
		y=aY/len;
		z=aZ/len;
		
		c=cos(len);
		s=sin(len);
		
		dcm[0][0]=c+(1-c)*x*x;
		dcm[0][1]=(1-c)*x*y+s*(-z);
		dcm[0][2]=(1-c)*x*z+s*y;
		dcm[1][0]=(1-c)*y*x+s*z;
		dcm[1][1]=c+(1-c)*y*y;
		dcm[1][2]=(1-c)*y*z+s*(-y);
		dcm[2][0]=(1-c)*z*x+s*(-y);
		dcm[2][1]=(1-c)*z*y+s*x;
		dcm[2][2]=c+(1-c)*z*z;
	}
	
	theta=asin(-dcm[2][0]);
	
	if (fabs(cos(y))>LDBL_MIN) {
		phi=atan2(dcm[2][1], dcm[2][2]);
		psi=atan2(dcm[1][0], dcm[0][0]);
	}
	else {
		psi=0;
		phi=atan2(dcm[0][1], dcm[1][1]);
	}	

}

-(void)UAV_TaskBoundary
{
	targetPosition[0]=(targetPosition[0]<-1800)?-1800:targetPosition[0];
	targetPosition[0]=(targetPosition[0]>1800)?1800:targetPosition[0];
	targetPosition[1]=(targetPosition[1]<-1500)?-1500:targetPosition[1];
	targetPosition[1]=(targetPosition[1]>1500)?1500:targetPosition[1];
}

-(void)UAV_XYController
{
	//Present Velocity
	x_velocity=(x_position-x_previousPosition)/0.02;
	y_velocity=(y_position-y_previousPosition)/0.02;
	
	//UAV_X_error & UAV_Y_error
	x_error=targetPosition[0]-x_position;
	y_error=targetPosition[1]-y_position;
	
	double kx=1.25;
	double ky=1.25;
	
	if (x_error<200) {
		kx=0.7;
	}
	if (y_error<200) {
		ky=0.7;
	}
	
	x_velocityError=(kx*x_error-x_velocity);
	y_velocityError=(ky*y_error-y_velocity);
	
	x_integral_velocityError+=x_velocityError;
	y_integral_velocityError+=y_velocityError;
	
	
	//x_integral_velocityError & y_integral_velocityError
	if (x_integral_velocityError>2100000000) {
		x_integral_velocityError=2100000000;
	}
	if (x_integral_velocityError<-2100000000) {
		x_integral_velocityError=-2100000000;
	}
	if (y_integral_velocityError>2100000000) {
		y_integral_velocityError=2100000000;
	}
	if (y_integral_velocityError<-2100000000) {
		y_integral_velocityError=-2100000000;
	}
	
	
	//x_derivative_velocityerror & y_derivative_velocityerror
	x_derivative_velocityError=x_velocityError-x_previous_velocityError;
	y_derivative_velocityError=y_velocityError-y_previous_velocityError;
	
	//x_output & y_output
	x_output=(int)round(x_velocityError*0.006f+x_integral_velocityError*0.000010f+x_derivative_velocityError*0.008f);
	y_output=(int)round(y_velocityError*0.008f+y_integral_velocityError*0.000008f+y_derivative_velocityError*0.007f);
	
	x_output=(x_output>6)?6:x_output;
	x_output=(x_output<-6)?-6:x_output;
	y_output=(y_output>4)?4:y_output;
	y_output=(y_output<-6)?-6:y_output;
	
	//store x_velocityerror and y_velocityerror to x_previous_velocityerror and y_previous_velocityerror
	x_previous_velocityError=x_velocityError;
	y_previous_velocityError=y_velocityError;
	
	//translate X,Y output into Roll and Picth.
	targetPitchAngle=x_output-4.2f;
	targetRollAngle=-y_output+3.2f;
	
	
	//General-tuning scaler
	double scaler=1.0f;
	
	//calculate angles' errors
	pitch_error=scaler*(targetPitchAngle-pitchAngle);
	roll_error=scaler*(targetRollAngle-rollAngle);
	
	pitch_output=129-((int)round(pitch_error*2.0));
	roll_output=131+((int)round(roll_error*3.0));
	pitch_output=(pitch_output>200)?200:pitch_output;
	pitch_output=(pitch_output<1)?1:pitch_output;
	roll_output=(roll_output>200)?200:roll_output;
	roll_output=(roll_output<1)?1:roll_output;
	
	pitchValue=(Byte)((int)pitch_output);
	rollValue=(Byte)((int)roll_output);
	
}

-(void)UAV_ZController
{
	//present velocity
	z_velocity=(z_position-z_previousPosition)/0.02;
	
	//z error
	z_error=targetPosition[2]-z_position;
	if (z_error>1000.0f) {
		z_error=1000.0f;
	}
	if (z_error<-1000.0f) {
		z_error=-1000.0f;
	}
	
	//z integral error
    z_integral_error+=z_error;
	if(z_integral_error>2100000000)
	{
		z_integral_error=2100000000;
	}
	if (z_integral_error<-2100000000) {
		z_integral_error=-2100000000;
	}
	
	//z derivative error
	z_derivative_error=z_error-z_previous_error;
	//z_output=150+(int)round(z_error*0.0323f+z_integral_error*0+z_derivative_error*2.5f);
	
	z_output=150+(int)round(z_error*0.0323f+z_integral_error*0.00025f+z_derivative_error*2.5f);

	
	z_output=(z_output>250)?250:z_output;
	z_output=(z_output<135)?135:z_output;
	
	//store z_error to z_previous_error
	z_previous_error=z_error;
	
	throlltleValue=(Byte)((int)z_output);
	
	yaw_error=-yawAngle;
	yaw_integral_error+=yaw_error;
	yaw_output=128-(int)round(5.75f*yaw_error+0.08f*yaw_integral_error);
	yaw_output=(yaw_output>200)?200:yaw_output;
	yaw_output=(yaw_output<1)?1:yaw_output;
	
	yawValue=(Byte)((int)yaw_output);
}

-(void)TaskManager
{
	//update angle data
	aX= x_angle;
	aY= y_angle;
	aZ =z_angle;
	[self angleConversion];
	
	//convert present angles to degree unit
	rollAngle=(double)((180/M_PI)*phi);
	pitchAngle=(double)((180/M_PI)*theta);
	yawAngle=(double)((180/M_PI)*psi);
	
	
	switch (uav_State) {
		case Ground:
			
			//initial state, do nothing (cutoff the throlltle)
			throlltleValue=0x01;
			
			//clear previous data
			x_previousPosition=x_position;
			y_previousPosition=y_position;
			z_previousPosition=z_position;
			
			//clear integral errors
			x_integral_velocityError=0;
			y_integral_velocityError=0;
			z_integral_error=0;
			yaw_integral_error=0;
			
			//clear previous error data
			x_previous_velocityError=0;
			y_previous_velocityError=0;
			z_previous_error=0;	
			break;
		case Landing:
			//maintain the standby XY position
			targetPosition[0]=standByPos0;
			targetPosition[1]=standByPos1;
			
			if (landingReady) {
				
				
				//start landing
				if (z_velocity>0 && z_velocity<2 && fabs(x_error) <100 && fabs(y_error) <100 ) {
					targetPosition[2]=targetPosition[2]*0.5;
					if (z_position<cutThrolltleHeight) {
						uav_State=Ground;
						
					}
				}
				
				
				//remove the bounce in landing procedure
				if (z_position<20 && fabs(x_error)<100 && fabs(y_error)<100) {
					if (z_position<cutThrolltleHeight) {
						uav_State=Ground;
						
					}
				}
			}
			else {
				targetPosition[2]=standByPos2;
				if (controllFlag) {
					landingReady=TRUE;
				    
				}
			}
			
			[self UAV_ZController];
			[self UAV_XYController];
			[self stateSwitcher];
			break;
		case TakingOff:
			
			targetPosition[0]=takeOffPos0;
			targetPosition[1]=takeOffPos1;
			targetPosition[2]=standByPos2;
			[self UAV_ZController];
			[self UAV_XYController];
			[self stateSwitcher];
			break;
			
		case Standby:
			
			targetPosition[0]=standByPos0;
			targetPosition[1]=standByPos1;
			targetPosition[2]=standByPos2;
			[self UAV_ZController];
			[self UAV_XYController];
			[self stateSwitcher];
			break;


	}
	
	x_previousPosition=x_position;
	y_previousPosition=y_position;
	z_previousPosition=z_position;
	
}


@end
