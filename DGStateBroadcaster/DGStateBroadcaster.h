//
//  DGStateBroadcaster.h
//
//  Created by Daniel Cohen Gindi on 5/8/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
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

- (void)stateBroadcasterBatteryChargedLow:(BOOL)isLow charging:(BOOL)isCharging;
- (void)stateBroadcasterDistanceTravelledToLocation:(CLLocation *)location;
- (void)stateBroadcasterLocationAccurateEnough:(BOOL)accurateEnough;
- (void)stateBroadcasterNetworkReachable:(BOOL)rechable isOnWifi:(BOOL)wifi;

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

+ (void)setReachabilityWithHostname:(NSString *)hostname;
+ (void)setReachabilityWithAddress:(const struct sockaddr_in *)hostAddress;
+ (void)setReachabilityForInternetConnection; // This is the default mode
+ (void)setReachabilityForWifiInternetConnection;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
+ (void)setLocationPurpose:(NSString *)purpose;
#endif
+ (void)setLocationActivityType:(CLActivityType)activityType;
+ (CLAuthorizationStatus)locationAuthorizationStatus;

#pragma mark Getters

+ (BOOL)isBatteryCurrentlyLow;
+ (BOOL)isBatteryCurrentlyCharging;
+ (float)currentBatteryLevel;

+ (BOOL)isReachable; // Available only when listening to reachability!
+ (BOOL)isOnWifi; // Available only when listening to reachability!
+ (NSString *)wifiIpAddress;

@end
