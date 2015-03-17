//
//  CompassViewController.m
//  sunglance
//
//  Created by Takako INOUE on 2015/01/04.
//  Copyright (c) 2015年 Gunu App. All rights reserved.
//

#import "CompassViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SharedManager.h"
#import "BLEManager.h"

@interface CompassViewController () <CLLocationManagerDelegate, BLEManagerDelegate>{
    SharedManager *manage;
    CLLocationManager *locationManager;
    BOOL headingAvailable;
    CLLocationDirection currentDir;
    NSString *value;
}

@property BLEManager *bleManager;

@end

@implementation CompassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    value = @"none";

    manage = [SharedManager sharedInstance];
    manage.currentLat = 0.0f;
    manage.currentLong = 0.0f;
    _targetNameLabel.text = manage.targetName;


    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc] init];
    headingAvailable = [CLLocationManager headingAvailable];
    if (headingAvailable) {
        locationManager.delegate = self;
        // 方位情報取得開始
        [locationManager startUpdatingHeading];
    }

    [locationManager requestAlwaysAuthorization];
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降

        // 位置情報測位の許可を求めるメッセージを表示する
        [locationManager requestAlwaysAuthorization]; // 常に許可
        //[locationManager requestWhenInUseAuthorization]; // 使用中のみ許可
    } else { // iOS7以前
        // 位置測位スタート
        [locationManager startUpdatingLocation];
        
    }
    
    _bleManager = [BLEManager sharedInstance];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {

}


-(void)changeValue: (NSString*)newVlue{
    NSLog(@"HOY");
    if([value compare:newVlue] == NSOrderedSame){
        return;
    }
    value = newVlue;
    [self postData:self];

}

- (void)postData:(id)sender
{
    NSLog(@"HEY!!");

    NSURL* url = [NSURL URLWithString:@"http://api-m2x.att.com/v2/devices/f55a360d640c724a5c6961ebbd3d812a/streams/action/value"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    // postするテキスト
    NSData* data =  [[NSString stringWithFormat:@
                                            "{\"value\":\"%@\"}",value] dataUsingEncoding:NSUTF8StringEncoding];

    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"71e151c604574ddd73d25c725689103b" forHTTPHeaderField:@"X-M2X-KEY"];
    request.HTTPBody = data;
    NSURLSessionDataTask* task =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
     {
         if(error){
             NSLog(@"Network ERROR");
             dispatch_async(dispatch_get_main_queue(), ^{
                 //
             });
             return;
         }
         if(data){
             NSString *str =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"RECV:%@",str);
             NSError *e = nil;
             NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&e];
             if(e){
                 NSLog(@"JSON ERROR");
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //
                 });
                 return;
             }
             if(!dict[@"token"]){
                 NSLog(@"TOKEN ERROR");
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //
                 });
                 return;
             }

             NSLog(@"Network OK");
             dispatch_async(dispatch_get_main_queue(), ^{
                 //
             });
             return;
         }
     }];
    [task resume];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    //return YES;
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {

        // 位置測位スタート
        [locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *newLocation = [locations lastObject];

    NSLog(@"%f %f",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);

    // 位置測位を終了する
    //[_locationManager stopUpdatingLocation];

    manage.currentLat =newLocation.coordinate.latitude;
    manage.currentLong =newLocation.coordinate.longitude;
    
}


float CalculateAngle(float nLat1, float nLon1, float nLat2, float nLon2)
{

    float dlat = nLat1 - nLat2;
    float dlong = nLon1 - nLon2;

    if( dlong < 0){
        return 90 - (atan(dlat/dlong) * 360);
    }
    if(dlong >=0){
        return 270 + (atan(abs(dlat)/abs(dlong)) * 360);
    }
    return 0.0f;
}
- (IBAction)onTouchClose:(id)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)BLEConnected:(NSString *)uuid {
    [_bleManager send: uuid];
}

- (void)BLEReceived:(NSString *)receivedText {
    NSArray *line =[receivedText componentsSeparatedByString:@"EOL"];
    NSArray *token = [line[0] componentsSeparatedByString:@":"];
    NSString *x = token[0];
    NSString *y = token[1];
    //NSString *z = token[2];
    
    double azimuth = atanf((double)[x doubleValue]/[y doubleValue]);
    
    double target_azimuth = azimuth;
    NSLog(@"DEG: %f",target_azimuth);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    _compass.transform = CGAffineTransformMakeRotation(-(M_PI * (target_azimuth / 180)));
    [UIView commitAnimations];
    
    if((target_azimuth > 60  && target_azimuth < 180)|| target_azimuth < -180){
        NSLog(@"LEFT");
        [self changeValue: @"leftled"];
        [_bleManager send: @"L"];
    }else if ((target_azimuth < -60  &&  target_azimuth > -180)|| target_azimuth >180){
        NSLog(@"RIGHT");
        [self changeValue: @"rightled"];
        [_bleManager send: @"R"];
    }else{
        [self changeValue: @"none"];
        [_bleManager send: @"S"];
    }
}
@end
