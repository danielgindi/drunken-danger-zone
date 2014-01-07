//
//  DGStateBroadcaster.h
//
//  Created by Daniel Cohen Gindi on 5/8/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  The MIT License (MIT)
//  
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE. 
//  

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <netinet/in.h>

typedef enum _DGStateBroadcasterState
{
    DGStateBroadcasterLowBattery = 0x01,
    DGStateBroadcasterDistanceTravelled = 0x02,
    DGStateBroadcasterLocationAccuracy = 0x04,
    DGStateBroadcasterNetworkReachability = 0x08,
} DGStateBroadcasterState;

@class DGStateBroadcaster;
@protocol DGStateBroadcasterDelegate <NSObject>

@optional - (void)stateBroadcasterBatteryChargedLow:(BOOL)isLow charging:(BOOL)isCharging;
@optional - (void)stateBroadcasterDistanceTravelledToLocation:(CLLocation*)location;
@optional - (void)stateBroadcasterLocationAccurateEnough:(BOOL)accurateEnough;
@optional - (void)stateBroadcasterNetworkReachable:(BOOL)reachable isOnWifi:(BOOL)wifi;

@end

@interface DGStateBroadcaster : NSObject

+ (void)addDelegate:(__unsafe_unretained id<DGStateBroadcasterDelegate>)delegate;
+ (void)removeDelegate:(__unsafe_unretained id<DGStateBroadcasterDelegate>)delegate;
+ (void)removeAllDelegates;

+ (void)startListeningTo:(DGStateBroadcasterState)states;
+ (void)stopListeningTo:(DGStateBroadcasterState)states;
+ (void)stopListeningToAllStates;

+ (void)startListeningToLowBatteryWithBar:(float)batteryCharge; // Default: 0.05
+ (void)startListeningToDistanceTravelledWithBarInMeters:(double)meters; // Default: 30
+ (void)startListeningToLocationAccuracyWithBarInMeters:(double)meters; // Default: 100m

#pragma mark Setters

+ (void)setDistanceTravelledBarInMeters:(double)meters;
+ (void)setLocationAccuracyBarInMeters:(double)meters;
+ (void)setLowBatteryBar:(float)batteryCharge;

+ (void)setReachabilityWithHostname:(NSString*)hostname;
+ (void)setReachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
+ (void)setReachabilityForInternetConnection; // This is the default mode
+ (void)setReachabilityForWifiInternetConnection;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
+ (void)setLocationPurpose:(NSString*)purpose;
#endif
+ (void)setLocationActivityType:(CLActivityType)activityType;
+ (CLAuthorizationStatus)locationAuthorizationStatus;

#pragma mark Getters

+ (BOOL)isBatteryCurrentlyLow;
+ (BOOL)isBatteryCurrentlyCharging;
+ (float)currentBatteryLevel;

+ (BOOL)isReachable; // Available only when listening to reachability!
+ (BOOL)isOnWifi; // Available only when listening to reachability!
+ (NSString*)wifiIpAddress;

@end
