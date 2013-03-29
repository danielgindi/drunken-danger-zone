//
//  DGLocationManager.h
//  DGLocationManager
//
//  Created by Daniel Cohen Gindi on 11/23/12.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//
//  General Location Manager Class.
//  Thread safe.
//  No instances required.
//  Delegates are called on main queue.
//  Starts updating location automatically when first delegate is added.
//  Stops updating location automatically when last delegate is removed.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class DGLocationManager;
@protocol DGLocationManagerDelegate <NSObject>

@optional
- (void)locationManagerDidUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManagerDidFailWithError:(NSError *)error;
- (void)locationManagerDidUpdateHeading:(CLHeading *)newHeading;
- (void)locationManagerDidChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end

@interface DGLocationManager : NSObject <CLLocationManagerDelegate>

+ (void)startUpdatingLocation;
+ (void)stopUpdatingLocation;

+ (void)startUpdatingHeading;
+ (void)stopUpdatingHeading;

+ (void)addLocationDelegate:(__weak id<DGLocationManagerDelegate>)delegate;
+ (void)removeLocationDelegate:(__weak id<DGLocationManagerDelegate>)delegate;
+ (void)removeAllLocationDelegates;

+ (void)addHeadingDelegate:(__weak id<DGLocationManagerDelegate>)delegate;
+ (void)removeHeadingDelegate:(__weak id<DGLocationManagerDelegate>)delegate;
+ (void)removeAllHeadingDelegates;

+ (void)setLocationPurpose:(NSString*)purpose;
+ (void)setLocationActivityType:(CLActivityType)activityType;

+ (CLLocation*)location;
+ (CLLocation*)previousLocation;

+ (double)magneticHeading;
+ (double)trueHeading;
+ (double)headingAccuracy;

+ (CLAuthorizationStatus)authorizationStatus;

@end
