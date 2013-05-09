//
//  DGStateBroadcaster.m
//
//  Created by Daniel Cohen Gindi on 5/8/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//

#import "DGStateBroadcaster.h"
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet6/in6.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

@interface DGStateBroadcaster () <CLLocationManagerDelegate>
{
    NSMutableArray *delegates;
    
    CLLocationManager *locationManager;
    NSString *locationPurpose;
    CLActivityType locationActivityType;
    CLLocation *lastLocation;
    
    BOOL isListeningToBattery;
    float batteryPercentageBar;
    BOOL lastBatteryMessageLow;
    BOOL lastBatteryMessageHigh;
    
    BOOL isListeningToDistanceTravelled;
    double distanceMetersBar;
    
    BOOL isListeningToLocationAccuracy;
    double locationAccuracyMetersBar;
    
    BOOL isListeningToNetworkReachability;
    SCNetworkReachabilityRef reachabilityRef;
    BOOL isReachabilityWifiOnly;
    struct sockaddr_in reachabilityAddress;
    BOOL hasReachabilityAddress;
    NSString *reachabilityHost;
    dispatch_queue_t reachabilityQueue;
}
@end

@implementation DGStateBroadcaster

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    CFRelease(reachabilityRef);
    reachabilityRef = NULL;
}

+ (DGStateBroadcaster*)instance
{
    static DGStateBroadcaster *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DGStateBroadcaster alloc] init];
        sharedInstance->delegates = [[NSMutableArray alloc] init];
        sharedInstance->batteryPercentageBar = .05f;
        sharedInstance->distanceMetersBar = 30.0;
        sharedInstance->locationAccuracyMetersBar = 100.0;
        sharedInstance->locationManager = [[CLLocationManager alloc] init];
        sharedInstance->locationManager.distanceFilter = kCLDistanceFilterNone;
        sharedInstance->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        sharedInstance->locationManager.headingFilter = kCLHeadingFilterNone;
        sharedInstance->locationManager.delegate = sharedInstance;
        sharedInstance->locationActivityType = CLActivityTypeOther;
    });
    return sharedInstance;
}

+ (void)addDelegate:(__unsafe_unretained id<DGStateBroadcasterDelegate>)delegate
{
    if (![NSThread isMainThread])
    {
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self addDelegate:delegate];
        });
    }
    
    DGStateBroadcaster *instance = self.instance;
    if ([instance->delegates containsObject:delegate]) return;
    [instance->delegates addObject:delegate];
    
    [self startUpdatingLocationIfNeeded];
}

+ (void)removeDelegate:(__unsafe_unretained id<DGStateBroadcasterDelegate>)delegate
{
    if (![NSThread isMainThread])
    {
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeDelegate:delegate];
        });
    }
    
    DGStateBroadcaster *instance = self.instance;
    [instance->delegates removeObject:delegate];
    if (instance->delegates.count == 0)
    {
        [self stopUpdatingLocationIfNotNeeded];
    }
}

+ (void)removeAllDelegates
{
    if (![NSThread isMainThread])
    {
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeAllDelegates];
        });
    }
    
    DGStateBroadcaster *instance = self.instance;
    [instance->delegates removeAllObjects];
    [self stopUpdatingLocationIfNotNeeded];
}

+ (void)startUpdatingLocationIfNeeded
{
    DGStateBroadcaster *instance = self.instance;
    if (instance->isListeningToDistanceTravelled || instance->isListeningToLocationAccuracy)
    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        if ([instance->locationManager respondsToSelector:@selector(setPurpose:)])
        {
            instance->locationManager.purpose = instance->locationPurpose;
        }
#endif
        if ([instance->locationManager respondsToSelector:@selector(setActivityType:)])
        {
            instance->locationManager.activityType = instance->locationActivityType;
        }
        [instance->locationManager startUpdatingLocation];
    }
}

+ (void)stopUpdatingLocationIfNotNeeded
{
    DGStateBroadcaster *instance = self.instance;
    if (!instance->isListeningToDistanceTravelled && !instance->isListeningToLocationAccuracy)
    {
        [instance->locationManager stopUpdatingLocation];
    }
}

+ (void)startListeningTo:(DGStateBroadcasterState)states
{
    DGStateBroadcaster *instance = self.instance;
    if ((states & DGStateBroadcasterLowBattery) == DGStateBroadcasterLowBattery)
    {
        UIDevice.currentDevice.batteryMonitoringEnabled = YES;
        if (!instance->isListeningToBattery)
        {
            [[NSNotificationCenter defaultCenter] addObserver:instance
                                                     selector:@selector(batteryLevelChanged:)
                                                         name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        }
        instance->isListeningToBattery = YES;
    }
    if ((states & DGStateBroadcasterDistanceTravelled) == DGStateBroadcasterDistanceTravelled && !instance->isListeningToDistanceTravelled)
    {
        [self startUpdatingLocationIfNeeded];
        instance->isListeningToDistanceTravelled = YES;
    }
    if ((states & DGStateBroadcasterLocationAccuracy) == DGStateBroadcasterLocationAccuracy && !instance->isListeningToLocationAccuracy)
    {
        [self startUpdatingLocationIfNeeded];
        instance->isListeningToLocationAccuracy = YES;
    }
    if ((states & DGStateBroadcasterNetworkReachability) == DGStateBroadcasterNetworkReachability)
    {
        [instance initReachabilityIfNeeded:NO];
        instance->isListeningToNetworkReachability = YES;
    }
}

+ (void)stopListeningTo:(DGStateBroadcasterState)states
{
    DGStateBroadcaster *instance = self.instance;
    if ((states & DGStateBroadcasterLowBattery) == DGStateBroadcasterLowBattery)
    {
        UIDevice.currentDevice.batteryMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:instance name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        instance->isListeningToBattery = NO;
    }
    if ((states & DGStateBroadcasterDistanceTravelled) == DGStateBroadcasterDistanceTravelled && instance->isListeningToDistanceTravelled)
    {
        [self stopUpdatingLocationIfNotNeeded];
        instance->isListeningToDistanceTravelled = NO;
    }
    if ((states & DGStateBroadcasterLocationAccuracy) == DGStateBroadcasterLocationAccuracy && instance->isListeningToLocationAccuracy)
    {
        [self stopUpdatingLocationIfNotNeeded];
        instance->isListeningToLocationAccuracy = NO;
    }
    if ((states & DGStateBroadcasterNetworkReachability) == DGStateBroadcasterNetworkReachability)
    {
        [instance destroyReachability];
        instance->isListeningToNetworkReachability = NO;
    }
}

+ (void)stopListeningToAllStates
{
    [self stopListeningTo:DGStateBroadcasterLowBattery | DGStateBroadcasterDistanceTravelled | DGStateBroadcasterNetworkReachability];
}

+ (void)startListeningToLowBatteryWithBar:(float)batteryCharge
{
    self.instance->batteryPercentageBar = batteryCharge;
    [self startListeningTo:DGStateBroadcasterLowBattery];
}

+ (void)startListeningToDistanceTravelledWithBarInMeters:(double)distanceMetersBar
{
    self.instance->distanceMetersBar = distanceMetersBar;
    [self startListeningTo:DGStateBroadcasterDistanceTravelled];
}

+ (void)startListeningToLocationAccuracyWithBarInMeters:(double)meters
{
    self.instance->locationAccuracyMetersBar = meters;
    [self startListeningTo:DGStateBroadcasterLocationAccuracy];
}

+ (void)setDistanceTravelledBarInMeters:(double)meters
{
    self.instance->distanceMetersBar = meters;
}

+ (void)setLocationAccuracyBarInMeters:(double)meters
{
    self.instance->locationAccuracyMetersBar = meters;
}

+ (void)setLowBatteryBar:(float)batteryCharge
{
    self.instance->batteryPercentageBar = batteryCharge;
}

static NSString *s_DGStateBroadcaster_RechabilitySync = @"s_DGStateBroadcaster_RechabilitySync";

- (void)initReachabilityIfNeeded:(BOOL)force
{
    @synchronized(s_DGStateBroadcaster_RechabilitySync)
    {
        if (reachabilityRef && !force) return;
        if (reachabilityRef)
        {
            CFRelease(reachabilityRef);
            reachabilityRef = NULL;
        }
        if (reachabilityHost.length)
        {
            reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, reachabilityHost.UTF8String);
        }
        else
        {
            struct sockaddr_in addr;
            
            if (hasReachabilityAddress)
            {
                addr = reachabilityAddress;
            }
            else
            {
                if (isReachabilityWifiOnly)
                {
                    bzero(&addr, sizeof(addr));
                    addr.sin_len            = sizeof(addr);
                    addr.sin_family         = AF_INET;
                    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
                    addr.sin_addr.s_addr    = htonl(IN_LINKLOCALNETNUM);
                }
                else
                {
                    bzero(&addr, sizeof(addr));
                    addr.sin_len = sizeof(addr);
                    addr.sin_family = AF_INET;
                }
            }
            reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&addr);
        }
        
        if (!reachabilityQueue)
        {
            reachabilityQueue = dispatch_queue_create("DGStateBroadcaster-reachability", NULL);
        }
        SCNetworkReachabilityContext context = { 0, NULL, NULL, NULL, NULL };
        context.info = (__bridge void *)self;
        
        if (SCNetworkReachabilitySetCallback(reachabilityRef, DGStateBroadcaster_ReachabilityCallback, &context))
        {
            // set it as our reachability queue which will retain the queue
            if(!SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilityQueue))
            {
                NSLog(@"DGStateBroadcaster: Reachability- can't set dispatch queue");
            }
        }
        else
        {
            NSLog(@"DGStateBroadcaster: Reachability- can't set callback!");
        }
    }
}

- (void)destroyReachability
{
    if (!reachabilityRef) return;
    @synchronized(s_DGStateBroadcaster_RechabilitySync)
    {
        CFRelease(reachabilityRef);
    }
}

static void DGStateBroadcaster_ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void*info)
{
#pragma unused (target)
    DGStateBroadcaster *_self = ((__bridge DGStateBroadcaster*)info);
    
    [_self reachabilityChanged:flags];
}

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags
{
    BOOL reachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    reachable = reachable && !needsConnection;
    
    NSString *wifiAddress = self.class.wifiIpAddress;
    
    if (reachable)
    {
        BOOL isCellularConnection = ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
        reachable = reachable && (isCellularConnection || !!wifiAddress.length);
    }
    
    BOOL isReachable = reachable;
    BOOL isReachableOnWifi = !!wifiAddress.length;
    
    // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<DGStateBroadcasterDelegate> delegate in delegates)
        {
            if ([delegate respondsToSelector:@selector(stateBroadcasterNetworkReachable:isOnWifi:)])
            {
                [delegate stateBroadcasterNetworkReachable:isReachable isOnWifi:isReachableOnWifi];
            }
        }
    });
}

+ (BOOL)isReachable
{
    DGStateBroadcaster *instance = self.instance;
	if (instance->reachabilityRef)
	{
		SCNetworkReachabilityFlags flags = 0;
		if(SCNetworkReachabilityGetFlags(self.instance->reachabilityRef, &flags))
		{
			BOOL reachable = ((flags & kSCNetworkFlagsReachable) != 0);
			BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
			reachable = reachable && !needsConnection;
			
			NSString *wifiAddress = self.wifiIpAddress;
			
			if (reachable)
			{
				BOOL isCellularConnection = ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
				reachable = reachable && (isCellularConnection || !!wifiAddress.length);
			}
    
			return reachable;
		}
		else
		{
			return NO;
		}
	}
    return NO;
}

+ (BOOL)isOnWifi
{
    DGStateBroadcaster *instance = self.instance;
	NSString *wifiAddress = self.wifiIpAddress;
	return !!wifiAddress.length;
}

+ (NSString*)wifiIpAddress
{ // Thanks to Matt Brown!
    BOOL success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) // this second test keeps from picking up the loopback address
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"]) { // found the WiFi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                }
            }
            
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return NULL;
}

+ (void)setReachabilityWithHostname:(NSString*)hostname
{
    DGStateBroadcaster *instance = self.instance;
    instance->hasReachabilityAddress = NO;
    instance->reachabilityHost = hostname;
    instance->isReachabilityWifiOnly = NO;
    [instance initReachabilityIfNeeded:YES];
}

+ (void)setReachabilityWithAddress:(const struct sockaddr_in*)hostAddress
{
    DGStateBroadcaster *instance = self.instance;
    instance->reachabilityAddress = *hostAddress;
    instance->hasReachabilityAddress = YES;
    instance->reachabilityHost = nil;
    instance->isReachabilityWifiOnly = NO;
    [instance initReachabilityIfNeeded:YES];
}

+ (void)setReachabilityForInternetConnection
{
    DGStateBroadcaster *instance = self.instance;
    instance->hasReachabilityAddress = NO;
    instance->reachabilityHost = nil;
    instance->isReachabilityWifiOnly = NO;
    [instance initReachabilityIfNeeded:YES];
}

+ (void)setReachabilityForWifiInternetConnection
{
    DGStateBroadcaster *instance = self.instance;
    instance->hasReachabilityAddress = NO;
    instance->reachabilityHost = nil;
    instance->isReachabilityWifiOnly = YES;
    [instance initReachabilityIfNeeded:YES];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
+ (void)setLocationPurpose:(NSString*)purpose
{
    self.instance->locationPurpose = [purpose copy];
}
#endif

+ (void)setLocationActivityType:(CLActivityType)activityType
{
    self.instance->locationActivityType = activityType;
}

+ (CLAuthorizationStatus)locationAuthorizationStatus
{
    return CLLocationManager.authorizationStatus;
}

+ (BOOL)isBatteryCurrentlyLow
{
    DGStateBroadcaster *instance = self.instance;
    BOOL enabled = UIDevice.currentDevice.batteryMonitoringEnabled;
    if (!enabled)
    {
        UIDevice.currentDevice.batteryMonitoringEnabled = YES;
    }
    BOOL ret = UIDevice.currentDevice.batteryLevel <= instance->batteryPercentageBar;
    UIDevice.currentDevice.batteryMonitoringEnabled = enabled;
    return ret;
}

+ (BOOL)isBatteryCurrentlyCharging
{
    BOOL enabled = UIDevice.currentDevice.batteryMonitoringEnabled;
    if (!enabled)
    {
        UIDevice.currentDevice.batteryMonitoringEnabled = YES;
    }
    BOOL ret = UIDevice.currentDevice.batteryState == UIDeviceBatteryStateCharging;
    UIDevice.currentDevice.batteryMonitoringEnabled = enabled;
    return ret;
}

+ (float)currentBatteryLevel
{
    BOOL enabled = UIDevice.currentDevice.batteryMonitoringEnabled;
    if (!enabled)
    {
        UIDevice.currentDevice.batteryMonitoringEnabled = YES;
    }
    float ret = UIDevice.currentDevice.batteryLevel;
    UIDevice.currentDevice.batteryMonitoringEnabled = enabled;
    return ret;
}

#pragma mark - Notifications

- (void)batteryLevelChanged:(NSNotification*)notification
{
    float batteryLevel = UIDevice.currentDevice.batteryLevel;
    BOOL isCharging = UIDevice.currentDevice.batteryState == UIDeviceBatteryStateCharging;
    if (batteryLevel <= batteryPercentageBar)
    {
        if (!lastBatteryMessageLow)
        {
            // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                for (id<DGStateBroadcasterDelegate> delegate in delegates)
                {
                    if ([delegate respondsToSelector:@selector(stateBroadcasterBatteryChargedLow:charging:)])
                    {
                        [delegate stateBroadcasterBatteryChargedLow:YES charging:isCharging];
                    }
                }
            });
            
            lastBatteryMessageLow = YES;
            lastBatteryMessageHigh = NO;
        }
    }
    else
    {
        if (!lastBatteryMessageHigh)
        {
            // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                for (id<DGStateBroadcasterDelegate> delegate in delegates)
                {
                    if ([delegate respondsToSelector:@selector(stateBroadcasterBatteryChargedLow:charging:)])
                    {
                        [delegate stateBroadcasterBatteryChargedLow:YES charging:isCharging];
                    }
                }
            });
            
            lastBatteryMessageHigh = YES;
            lastBatteryMessageLow = NO;
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (isListeningToDistanceTravelled && (!lastLocation || [lastLocation distanceFromLocation:newLocation] > distanceMetersBar))
    {
        lastLocation = newLocation;
        
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<DGStateBroadcasterDelegate> delegate in delegates)
            {
                if ([delegate respondsToSelector:@selector(stateBroadcasterDistanceTravelledToLocation:)])
                {
                    [delegate stateBroadcasterDistanceTravelledToLocation:newLocation];
                }
            }
        });
    }
    if (isListeningToLocationAccuracy)
    {
        BOOL isAcurateEnough = newLocation.horizontalAccuracy > locationAccuracyMetersBar;
        // NSMutableArray is NOT threadsafe! So only work with the delegates on main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<DGStateBroadcasterDelegate> delegate in delegates)
            {
                if ([delegate respondsToSelector:@selector(stateBroadcasterLocationAccurateEnough:)])
                {
                    [delegate stateBroadcasterLocationAccurateEnough:isAcurateEnough];
                }
            }
        });
    }
}

@end
