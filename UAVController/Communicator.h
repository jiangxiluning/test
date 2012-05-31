//
//  FetchData.h
//  Testing
//
//  Created by Ning Lu on 10-7-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PIDController.h"
@class AsyncSocket;
@class PIDController;


@interface Communicator : NSObject {
	AsyncSocket *listenSocket;
	AsyncSocket *clientSocket;
	
	NSMutableData *receivedData;
	NSMutableData *sentData;
	BOOL isClientConeected;
	PIDController *controller;
	


@private
	id _delegate;
}
+ (Communicator *)sharedCommunicator;

@property (nonatomic,retain) NSMutableData *receivedData;
@property (nonatomic,retain) NSMutableData *sentData;
@property (nonatomic,assign) BOOL isClientConeected;
//@property (nonatomic, retain) AsyncSocket *connectSocket;



-(void)setDelegateForSocket:(id)delegate;
-(BOOL)buildConnection;
-(BOOL)killConnection;
-(void)SendMessage:(NSString *)string;

@end
