//
//  BLEManager.h
//  offtalk
//
//  Created by Takako INOUE on 2014/11/30.
//  Copyright (c) 2014年 GunuApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerialGATT.h"

@protocol BLEManagerDelegate
@optional
-(void) BLEConnected:(NSString*)uuid;
-(void) BLEDisconnected;
-(void) BLEReceived:(NSString*)receivedText;
-(void) BLEStopScan;
-(void) BLEFailedToConnect;
-(void) BTPowerOff;
-(void) BTPowerOn;
@end

@interface BLEManager : NSObject <BTSmartSensorDelegate>{
    NSTimer *tm;
}
@property NSObject <BLEManagerDelegate> *delegate;
@property SerialGATT *sensor;
@property bool isConnected;
@property bool isBluetoothTurnedOn;


+ (BLEManager *)sharedInstance;

-(void)setup;
-(void)connectWithName:(NSString*) name;
-(void)disconnect;
-(void)send:(NSString*)sendText;

@end
