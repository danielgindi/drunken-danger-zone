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
    CLLocationManager * locationManager;
}
@end

@implementation DGLocationManager

static NSMutableArray * s_DGLocationManager_locationDelegates = nil;
static NSMutableArray * s_DGLocationManager_headingDelegates = nil;
static CLLocation * s_DGLocationManager_oldLocation = nil;
static CLLocation * s_DGLocationManager_newLocation = nil;
static NSString * s_DGLocationManager_purpose = nil;
static CLActivityType s_DGLocationManager_activityType = CLActivityTypeOther;

static double s_DGLocationManager_magneticHeading = 0.0;
static double s_DGLocationManager_trueHeading = 0.0;
static CLLocationDirection s_DGLocationManager_headingAccuracy = 0.0;

#define s_locationDelegates s_DGLocationManager_locationDelegates
#define s_headingDelegates s_DGLocationManager_headingDelegates
#define s_oldLocation s_DGLocationManager_oldLocation
#define s_newLocation s_DGLocationManager_newLocation
#define s_purpose s_DGLocationManager_purpose
#define s_activityType s_DGLocationManager_activityType
#define s_magneticHeading s_DGLocationManager_magneticHeading
#define s_trueHeading s_DGLocationManager_trueHeading
#define s_headingAccuracy s_DGLocationManager_headingAccuracy

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
    });
    return sharedInstance;
}

+ (void)initializeDelegates
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_locationDelegates = [[NSMutableArray alloc] init];
        s_headingDelegates = [[NSMutableArray alloc] init];
    });
}

+ (void)startUpdatingLocation
{
    DGLocationManager * instance = [DGLocationManager instance];
    if ([instance->locationManager respondsToSelector:@selector(setPurpose:)])
    {
        instance->locationManager.purpose = s_purpose;
    }
    if ([instance->locationManager respondsToSelector:@selector(setActivityType:)])
    {
        instance->locationManager.activityType = s_activityType;
    }
    [instance->locationManager startUpdatingLocation];
}

+ (void)stopUpdatingLocation
{
    [[self instance]->locationManager stopUpdatingLocation];
}

+ (void)startUpdatingHeading
{
    DGLocationManager * instance = [DGLocationManager instance];
    if ([instance->locationManager respondsToSelector:@selector(setPurpose:)])
    {
        instance->locationManager.purpose = s_purpose;
    }
    if ([instance->locationManager respondsToSelector:@selector(setActivityType:)])
    {
        instance->locationManager.activityType = s_activityType;
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
    
    if (!s_locationDelegates)
    {
        [self initializeDelegates];
    }
    
    if ([s_locationDelegates containsObject:delegate]) return;
    [s_locationDelegates addObject:delegate];
    
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
    
    [s_locationDelegates removeObject:delegate];
    if (s_locationDelegates.count == 0)
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
    
    [s_locationDelegates removeAllObjects];
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
    
    if (!s_headingDelegates)
    {
        [self initializeDelegates];
    }
    
    if ([s_headingDelegates containsObject:delegate]) return;
    [s_headingDelegates addObject:delegate];
    
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
    
    [s_headingDelegates removeObject:delegate];
    if (s_headingDelegates.count == 0)
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
    
    [s_headingDelegates removeAllObjects];
    [self stopUpdatingHeading];
}

+ (void)setLocationPurpose:(NSString*)purpose
{
    s_purpose = [purpose copy];
}

+ (void)setLocationActivityType:(CLActivityType)activityType
{
    s_activityType = activityType;
}

+ (CLLocation*)location
{
    return s_newLocation;
}

+ (CLLocation*)previousLocation
{
    return s_oldLocation;
}

+ (double)magneticHeading
{
    return s_magneticHeading;
}

+ (double)trueHeading
{
    return s_trueHeading;
}

+ (double)headingAccuracy
{
    return s_headingAccuracy;
}

+ (CLAuthorizationStatus)authorizationStatus
{
    return [CLLocationManager authorizationStatus];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    s_newLocation = newLocation;
    s_oldLocation = oldLocation;
    
    // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<DGLocationManagerDelegate> delegate in s_locationDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidUpdateToLocation:fromLocation:)])
            {
                [delegate locationManagerDidUpdateToLocation:newLocation fromLocation:oldLocation];
            }
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    s_magneticHeading = [newHeading magneticHeading];
    s_trueHeading = [newHeading trueHeading];
    s_headingAccuracy = [newHeading headingAccuracy];
    
    // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<DGLocationManagerDelegate> delegate in s_headingDelegates)
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
        for (id<DGLocationManagerDelegate> delegate in s_locationDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidFailWithError:)])
            {
                [delegate locationManagerDidFailWithError:error];
            }
        }
        for (id<DGLocationManagerDelegate> delegate in s_headingDelegates)
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
        for (id<DGLocationManagerDelegate> delegate in s_locationDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidChangeAuthorizationStatus:)])
            {
                [delegate locationManagerDidChangeAuthorizationStatus:status];
            }
        }
        for (id<DGLocationManagerDelegate> delegate in s_headingDelegates)
        {
            if ([delegate respondsToSelector:@selector(locationManagerDidChangeAuthorizationStatus:)])
            {
                [delegate locationManagerDidChangeAuthorizationStatus:status];
            }
        }
    });
}

@end
