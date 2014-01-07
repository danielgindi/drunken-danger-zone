//
//  DGLocationManager.h
//  DGLocationManager
//
//  Created by Daniel Cohen Gindi on 11/23/12.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  General Location Manager Class.
//  Thread safe.
//  No instances required.
//  Delegates are called on main queue.
//  Starts updating location automatically when first delegate is added.
//  Stops updating location automatically when last delegate is removed.
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

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
+ (void)setLocationPurpose:(NSString *)purpose;
#endif
+ (void)setLocationActivityType:(CLActivityType)activityType;

+ (CLLocation *)location;
+ (CLLocation *)previousLocation;

+ (double)magneticHeading;
+ (double)trueHeading;
+ (double)headingAccuracy;

+ (CLAuthorizationStatus)authorizationStatus;

@end
