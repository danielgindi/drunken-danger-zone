//
//  DGLocationManager.m
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

#import "DGLocationManager.h"

@interface DGLocationManager ()
{
    CLLocationManager *locationManager;
    
    NSMutableArray *locationDelegates;
    NSMutableArray *headingDelegates;
    CLLocation *oldLocation;
    CLLocation *newLocation;
    NSString *purpose;
    CLActivityType activityType;
    
    double magneticHeading;
    double trueHeading;
    CLLocationDirection headingAccuracy;
}
@end

@implementation DGLocationManager

+ (DGLocationManager*)instance
{
    static DGLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DGLocationManager alloc] init];
        sharedInstance->locationManager = [[CLLocationManager alloc] init];
        sharedInstance->locationManager.distanceFilter = kCLDistanceFilterNone;
        sharedInstance->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        sharedInstance->locationManager.headingFilter = kCLHeadingFilterNone;
        sharedInstance->locationManager.delegate = sharedInstance;
        sharedInstance->activityType = CLActivityTypeOther;
        sharedInstance->locationDelegates = [[NSMutableArray alloc] init];
        sharedInstance->headingDelegates = [[NSMutableArray alloc] init];
    });
    return sharedInstance;
}

+ (void)startUpdatingLocation
{
    DGLocationManager *instance = DGLocationManager.instance;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if ([instance->locationManager respondsToSelector:@selector(setPurpose:)])
    {
        instance->locationManager.purpose = instance->purpose;
    }
#endif
    if ([instance->locationManager respondsToSelector:@selector(setActivityType:)])
    {
        instance->locationManager.activityType = instance->activityType;
    }
    [instance->locationManager startUpdatingLocation];
}

+ (void)stopUpdatingLocation
{
    [[self instance]->locationManager stopUpdatingLocation];
}

+ (void)startUpdatingHeading
{
    DGLocationManager *instance = DGLocationManager.instance;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if ([instance->locationManager respondsToSelector:@selector(setPurpose:)])
    {
        instance->locationManager.purpose = instance->purpose;
    }
#endif
    if ([instance->locationManager respondsToSelector:@selector(setActivityType:)])
    {
        instance->locationManager.activityType = instance->activityType;
    }
    [instance->locationManager startUpdatingHeading];
}

+ (void)stopUpdatingHeading
{
    [[self instance]->locationManager stopUpdatingHeading];
}

+ (void)addLocationDelegate:(__unsafe_unretained id<DGLocationManagerDelegate>)delegate
{
    if (![NSThread isMainThread])
    {
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self addLocationDelegate:delegate];
        });
    }
    
    DGLocationManager *instance = DGLocationManager.instance;
    if ([instance->locationDelegates containsObject:delegate]) return;
    [instance->locationDelegates addObject:delegate];
    
    [self startUpdatingLocation];
}

+ (void)removeLocationDelegate:(__unsafe_unretained id<DGLocationManagerDelegate>)delegate
{
    if (![NSThread isMainThread])
    {
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeLocationDelegate:delegate];
        });
    }
    
    DGLocationManager *instance = DGLocationManager.instance;
    [instance->locationDelegates removeObject:delegate];
    if (instance->locationDelegates.count == 0)
    {
        [self stopUpdatingLocation];
    }
}

+ (void)removeAllLocationDelegates
{
    if (![NSThread isMainThread])
    {
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeAllLocationDelegates];
        });
    }
    
    DGLocationManager *instance = DGLocationManager.instance;
    [instance->locationDelegates removeAllObjects];
    [self stopUpdatingLocation];
}

+ (void)addHeadingDelegate:(__unsafe_unretained id<DGLocationManagerDelegate>)delegate
{
    if (![NSThread isMainThread])
    {
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self addHeadingDelegate:delegate];
        });
    }
    
    DGLocationManager *instance = DGLocationManager.instance;
    if ([instance->headingDelegates containsObject:delegate]) return;
    [instance->headingDelegates addObject:delegate];
    
    [self startUpdatingHeading];
}

+ (void)removeHeadingDelegate:(__unsafe_unretained id<DGLocationManagerDelegate>)delegate
{
    if (![NSThread isMainThread])
    {
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeHeadingDelegate:delegate];
        });
    }
    
    DGLocationManager *instance = DGLocationManager.instance;
    [instance->headingDelegates removeObject:delegate];
    if (instance->headingDelegates.count == 0)
    {
        [self stopUpdatingHeading];
    }
}

+ (void)removeAllHeadingDelegates
{
    if (![NSThread isMainThread])
    {
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeAllHeadingDelegates];
        });
    }
    
    DGLocationManager *instance = DGLocationManager.instance;
    [instance->headingDelegates removeAllObjects];
    [self stopUpdatingHeading];
}

+ (void)setLocationPurpose:(NSString*)purpose
{
    DGLocationManager.instance->purpose = [purpose copy];
}

+ (void)setLocationActivityType:(CLActivityType)activityType
{
    DGLocationManager.instance->activityType = activityType;
}

+ (CLLocation*)location
{
    return DGLocationManager.instance->newLocation;
}

+ (CLLocation*)previousLocation
{
    return DGLocationManager.instance->oldLocation;
}

+ (double)magneticHeading
{
    return DGLocationManager.instance->magneticHeading;
}

+ (double)trueHeading
{
    return DGLocationManager.instance->trueHeading;
}

+ (double)headingAccuracy
{
    return DGLocationManager.instance->headingAccuracy;
}

+ (CLAuthorizationStatus)authorizationStatus
{
    return [CLLocationManager authorizationStatus];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)theNewLocation
           fromLocation:(CLLocation *)theOldLocation
{
    newLocation = theNewLocation;
    oldLocation = theOldLocation;
    
    // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<DGLocationManagerDelegate> delegate in locationDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidUpdateToLocation:fromLocation:)])
            {
                [delegate locationManagerDidUpdateToLocation:theNewLocation fromLocation:theOldLocation];
            }
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    magneticHeading = newHeading.magneticHeading;
    trueHeading = newHeading.trueHeading;
    headingAccuracy = newHeading.headingAccuracy;
    
    // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<DGLocationManagerDelegate> delegate in headingDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidUpdateHeading:)])
            {
                [delegate locationManagerDidUpdateHeading:newHeading];
            }
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<DGLocationManagerDelegate> delegate in locationDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidFailWithError:)])
            {
                [delegate locationManagerDidFailWithError:error];
            }
        }
        for (id<DGLocationManagerDelegate> delegate in headingDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidFailWithError:)])
            {
                [delegate locationManagerDidFailWithError:error];
            }
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<DGLocationManagerDelegate> delegate in locationDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidChangeAuthorizationStatus:)])
            {
                [delegate locationManagerDidChangeAuthorizationStatus:status];
            }
        }
        for (id<DGLocationManagerDelegate> delegate in headingDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidChangeAuthorizationStatus:)])
            {
                [delegate locationManagerDidChangeAuthorizationStatus:status];
            }
        }
    });
}

@end
