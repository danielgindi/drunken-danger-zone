//
//  DGLocationManager.m
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

#import "DGLocationManager.h"

#define IS_OS_8_OR_LATER (UIDevice.currentDevice.systemVersion.floatValue >= 8.f)

#pragma mark - Wrapper for delegate to keep it unretained

@interface DGLocationManagerUnretainedWrapper : NSObject
{
@public
    __unsafe_unretained id reference;
}

+ (DGLocationManagerUnretainedWrapper *)wrapperForReference:(__unsafe_unretained id)aReference;

@end

#pragma mark - DGLocationManager main class

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

+ (DGLocationManager *)instance
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
    DGLocationManager *instance = self.instance;
    
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
    DGLocationManager *instance = self.instance;
	
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

+ (void)requestWhenInUseAuthorization
{
    if (IS_OS_8_OR_LATER)
    {
        [[self instance]->locationManager requestWhenInUseAuthorization];
    }
}

+ (void)requestAlwaysAuthorization
{
    if (IS_OS_8_OR_LATER)
    {
        [[self instance]->locationManager requestAlwaysAuthorization];
    }
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
    
    DGLocationManager *instance = self.instance;
    DGLocationManagerUnretainedWrapper *wrapper = [DGLocationManagerUnretainedWrapper wrapperForReference:delegate];
    if ([instance->locationDelegates containsObject:wrapper]) return;
    [instance->locationDelegates addObject:wrapper];
        
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
    
    DGLocationManager *instance = self.instance;
    DGLocationManagerUnretainedWrapper *wrapper = [DGLocationManagerUnretainedWrapper wrapperForReference:delegate];
    [instance->locationDelegates removeObject:wrapper];
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
    
    DGLocationManager *instance = self.instance;
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
    
    DGLocationManager *instance = self.instance;
    DGLocationManagerUnretainedWrapper *wrapper = [DGLocationManagerUnretainedWrapper wrapperForReference:delegate];
    if ([instance->headingDelegates containsObject:wrapper]) return;
    [instance->headingDelegates addObject:wrapper];
    
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
    
    DGLocationManager *instance = self.instance;
    DGLocationManagerUnretainedWrapper *wrapper = [DGLocationManagerUnretainedWrapper wrapperForReference:delegate];
    [instance->headingDelegates removeObject:wrapper];
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
    
    DGLocationManager *instance = self.instance;
    [instance->headingDelegates removeAllObjects];
    [self stopUpdatingHeading];
}

+ (void)setLocationPurpose:(NSString *)purpose
{
    self.instance->purpose = [purpose copy];
}

+ (void)setLocationActivityType:(CLActivityType)activityType
{
    self.instance->activityType = activityType;
}

+ (CLLocation *)location
{
    return self.instance->newLocation;
}

+ (CLLocation *)previousLocation
{
    return self.instance->oldLocation;
}

+ (double)magneticHeading
{
    return self.instance->magneticHeading;
}

+ (double)trueHeading
{
    return self.instance->trueHeading;
}

+ (double)headingAccuracy
{
    return self.instance->headingAccuracy;
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
        for (DGLocationManagerUnretainedWrapper *delegateWrapper in locationDelegates)
        {
            id<DGLocationManagerDelegate> delegate = delegateWrapper->reference;
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
        for (DGLocationManagerUnretainedWrapper *delegateWrapper in headingDelegates)
        {
            id<DGLocationManagerDelegate> delegate = delegateWrapper->reference;
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
        for (DGLocationManagerUnretainedWrapper *delegateWrapper in locationDelegates)
        {
            id<DGLocationManagerDelegate> delegate = delegateWrapper->reference;
            if ([delegate respondsToSelector:@selector(locationManagerDidFailWithError:)])
            {
                [delegate locationManagerDidFailWithError:error];
            }
        }
        for (DGLocationManagerUnretainedWrapper *delegateWrapper in headingDelegates)
        {
            id<DGLocationManagerDelegate> delegate = delegateWrapper->reference;
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
        for (DGLocationManagerUnretainedWrapper *delegateWrapper in locationDelegates)
        {
            id<DGLocationManagerDelegate> delegate = delegateWrapper->reference;
            if ([delegate respondsToSelector:@selector(locationManagerDidChangeAuthorizationStatus:)])
            {
                [delegate locationManagerDidChangeAuthorizationStatus:status];
            }
        }
        for (DGLocationManagerUnretainedWrapper *delegateWrapper in headingDelegates)
        {
            id<DGLocationManagerDelegate> delegate = delegateWrapper->reference;
            if ([delegate respondsToSelector:@selector(locationManagerDidChangeAuthorizationStatus:)])
            {
                [delegate locationManagerDidChangeAuthorizationStatus:status];
            }
        }
    });
}

@end

#pragma mark -
#pragma mark - DGLocationManagerUnretainedWrapper

@implementation DGLocationManagerUnretainedWrapper

- (id)initWithReference:(__unsafe_unretained id)aReference
{
    self = [super init];
    if (self)
    {
        reference = aReference;
    }
    return self;
}

+ (DGLocationManagerUnretainedWrapper *)wrapperForReference:(__unsafe_unretained id)aReference
{
    return [[DGLocationManagerUnretainedWrapper alloc] initWithReference:aReference];
}

- (BOOL)isEqual:(id)object
{
    return self == object || reference == ((DGLocationManagerUnretainedWrapper*)object)->reference;
}

@end
