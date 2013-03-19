//
//  DGLocationManager.h
//  DGLocationManager
//
//  Created by Daniel Cohen Gindi on 11/23/12.
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

+ (void)addLocationDelegate:(__unsafe_unretained id<DGLocationManagerDelegate>)delegate;
+ (void)removeLocationDelegate:(__unsafe_unretained id<DGLocationManagerDelegate>)delegate;
+ (void)removeAllLocationDelegates;

+ (void)addHeadingDelegate:(__unsafe_unretained id<DGLocationManagerDelegate>)delegate;
+ (void)removeHeadingDelegate:(__unsafe_unretained id<DGLocationManagerDelegate>)delegate;
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
