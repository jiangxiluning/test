//
//  FetchData.m
//  Testing
//
//  Created by Ning Lu on 10-7-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Communicator.h"
#import "AsyncSocket.h"



static Communicator *_sharedCommunicator;

@implementation Communicator

@synthesize receivedData;
@synthesize sentData;
@synthesize isClientConeected;
//@synthesize listenSocket;



+(Communicator *)sharedCommunicator
{
	if(!_sharedCommunicator){ 
		_sharedCommunicator=[[Communicator alloc] init];
	}
	return _sharedCommunicator;
}


-(id) init
{
	if (self=[super init]) {
		listenSocket=[[AsyncSocket alloc] init];
		[listenSocket setDelegate:self];
		[listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
		controller=[PIDController SharedPIDController];
	}
	return self;
}

-(void) dealloc
{
	[receivedData release];
	[sentData release];
	[listenSocket release];
	[clientSocket release];
	[_sharedCommunicator release];
	[super dealloc];
}


#pragma mark -
#pragma mark Instance Methods

//Set delegate for AsyncSocket object
-(void)setDelegateForSocket:(id)delegate
{
	[listenSocket setDelegate:delegate];
}



//Build Connection to Server
-(BOOL)buildConnection
{	
	NSError *error=nil;	
	BOOL islistening=[listenSocket acceptOnPort:12346 error:&error];
	if (!islistening) {
		NSLog(@"Error occurs when listening 12346 port.");
	}
	return islistening;
}

//Close the Connection which was built.
-(BOOL)killConnection
{
	[listenSocket disconnect];		
	[clientSocket disconnect];
	return [listenSocket isConnected];
}



//Send Data to Server.
-(void)SendMessage:(NSString *)string
{
	//Byte piddata[4]={yawValue,rollValue,pitchValue,throlltleValue};
	//NSData *requestData = [NSData dataWithBytes:&piddata length:(sizeof(Byte)*4)];
	//[clientSocket writeData:requestData withTimeout:-1 tag:1];
	
}

#pragma mark -
#pragma mark AsyncSocket Delegate Methods

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{

	[sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	receivedData  =[NSMutableData dataWithData:data];
	
	double temp;
	[data getBytes:&temp range:NSMakeRange(0,8)];controller.x_position=temp;
	[data getBytes:&temp range:NSMakeRange(8,8)];controller.y_position=temp;
	[data getBytes:&temp range:NSMakeRange(16,8)];controller.z_position=temp;
	[data getBytes:&temp range:NSMakeRange(24,8)];controller.x_angle=temp;
	[data getBytes:&temp range:NSMakeRange(32, 8)];controller.y_angle=temp;
	[data getBytes:&temp range:NSMakeRange(40, 8)];controller.z_angle=temp;
	
	
	[controller TaskManager];
	
	
	Byte piddata[4]={controller.yawValue,controller.rollValue,controller.pitchValue,controller.throlltleValue};
	
	[clientSocket writeData:[NSData dataWithBytes:&piddata length:(sizeof(Byte)*4)]  withTimeout:-1 tag:1];	
	
	
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	isClientConeected=TRUE;
	[sock readDataWithTimeout:-1 tag:0];
}



-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	clientSocket=newSocket;
	[clientSocket retain];
	NSLog(@"Accepted!");
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	clientSocket=nil;
	[clientSocket release];
	isClientConeected=FALSE;
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	isClientConeected=FALSE;
	NSLog(@"FUCK!");
}




#pragma mark -
#pragma mark Exception Handlers


@end
