//
//  ViewController.m
//  sunglance
//
//  Created by Takako INOUE on 2015/01/04.
//  Copyright (c) 2015年 Gunu App. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "CompassViewController.h"
#import "SharedManager.h"

@interface ViewController (){
    SharedManager *manager;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    manager = [SharedManager sharedInstance];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTouchSF:(id)sender {
    [self showCompas:@"San Francisco" lat:37.7128999f lon:-122.4211205f];

}
- (IBAction)onTouchNY:(id)sender {
    [self showCompas:@"New York" lat:40.7056258f lon:-73.97968f];

}
- (IBAction)onTouchTK:(id)sender {
        [self showCompas:@"Tokyo" lat:35.673343f lon:-139.710388f];

}
- (IBAction)onTouchBJ:(id)sender {
            [self showCompas:@"Beijing" lat:39.9388838f lon:116.3974589f];
}

-(void)showCompas:(NSString*)name lat:(float)lat lon:(float)lon  {
    manager.targetName = name;


    manager.targetLat = lat;
    manager.targetLong = lon;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompassView" bundle:nil];
    CompassViewController *compassViewController = [storyboard instantiateInitialViewController];
    [self presentViewController:compassViewController animated:YES completion:nil];

}

@end
