//
//  BLEManager.m
//  offtalk
//
//  Created by Takako INOUE on 2014/11/30.
//  Copyright (c) 2014年 GunuApp. All rights reserved.
//

#import "BLEManager.h"

@interface BLEManager ()
@property NSString *receiveBuffer;
@property bool receiveInProgress;
@property NSString *name;
@end

@implementation BLEManager
+ (instancetype)sharedInstance {
    static BLEManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
        [_sharedInstance setup];
    });
    return _sharedInstance;
}

-(void)setup
{
    _isConnected = NO;
    _sensor = [[SerialGATT alloc] init];
    _sensor.delegate = self;
    [_sensor setup];
}

-(void)connectWithName:(NSString*) name
{
    _name = name;
    [self disconnect];

    if ([_sensor peripherals]) {
        _sensor.peripherals = nil;
    }
    [_sensor findHMSoftPeripherals:2 ];
    tm = [NSTimer scheduledTimerWithTimeInterval:(float)3 target:self selector:@selector(connectTimer:) userInfo:nil repeats:NO];
}

-(void)connectTimer:(NSTimer *)timer
{
    if(_isConnected == NO){
        [_delegate BLEFailedToConnect];
    }
}

-(void)disconnect
{
    if( [_sensor activePeripheral]){
        if (_sensor.activePeripheral.state == CBPeripheralStateConnected) {
            NSLog(@"Disconnect");
            [_sensor disconnect:_sensor.activePeripheral];
        }
        _sensor.activePeripheral = nil;
    }
}

-(void)send:(NSString*)sendText
{
    NSData *data = [sendText dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"WRITE===");
    [_sensor write:_sensor.activePeripheral data:data];
    [self dataDump:data];
}

-(void)sensorReady
{
    NSLog(@"Sensor ready");
    //TODO: it seems useless right now.
}

-(void) peripheralFound:(CBPeripheral *)peripheral
{
    NSLog(@"Found!");
    NSLog(@"%@",peripheral.name);

    if([peripheral.name isEqualToString: [NSString stringWithFormat:@"%@",_name]]){
        NSLog(@"HAKAMA!!!");
        [_sensor stopScan];
        if([_sensor activePeripheral] && _sensor.activePeripheral != peripheral){
            [_sensor disconnect:_sensor.activePeripheral];
        }
        _sensor.activePeripheral = peripheral;
        [_sensor connect:_sensor.activePeripheral];
        NSLog(@"START CONNECT");
    }
}

//Connections
-(void) serialGATTCharValueUpdated:(NSString *)UUID value:(NSData *)data{
    [self dataDump:data];
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"RECV: %@",value);
    [_delegate BLEReceived:value];
}


-(void)setConnect
{
    _isConnected = YES;
    [tm invalidate];
    CFStringRef s = CFUUIDCreateString(kCFAllocatorDefault, (__bridge CFUUIDRef )_sensor.activePeripheral.identifier);
    NSString *uuid = (__bridge NSString*)s;
    NSLog(@"FIND_UUID:%@ OK+CONN!!!!",uuid);
    [_delegate BLEConnected:uuid];
}

-(void)setDisconnect
{
    _isConnected = NO;
    _sensor.activePeripheral = nil;
    NSLog(@"DISCONNECTED!!!!");
    if([_delegate respondsToSelector:@selector(BLEDisconnected)]){
        [_delegate BLEDisconnected];
    }
}

//Utils

-(void)dataDump:(NSData*)data
{
    NSLog(@"Data dump ---------");
    NSUInteger length =[data length];
    NSLog(@"Length: %lud", (unsigned long)length);
    Byte *byteData = (Byte*)malloc(length);
    memcpy(byteData, [data bytes], length);
    for(int i=0; i<length; i++){
        NSLog(@"%c %x", byteData[i], byteData[i]);
    }
}

//BT Sattus
-(void)BTPowerOff
{
    NSLog(@"Bluetooth Off");
    _isBluetoothTurnedOn = NO;
    if([_delegate respondsToSelector:@selector(BTPowerOff)]){
NSLog(@"Bluetooth Off!!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate BTPowerOff];
        });
    }
}

-(void)BTPowerOn
{
    NSLog(@"Bluetooth ON");
    _isBluetoothTurnedOn = YES;
    if([_delegate respondsToSelector:@selector(BTPowerOn)]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate BTPowerOn];
        });
    }
}


@end
