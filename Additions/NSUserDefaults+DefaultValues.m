//
//  NSUserDefaults+DefaultValues.m
//  Additions
//
//  Created by Daniel Cohen Gindi on 6/2/11.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "NSUserDefaults+DefaultValues.h"

@implementation NSUserDefaults (DefaultValues)

- (NSString *)stringForKey:(NSString *)defaultName orDefault:(NSString*)defaultValue
{
    NSString * ret = [self stringForKey:defaultName];
    if (!ret) return defaultValue;
    return ret;
}

- (NSArray *)arrayForKey:(NSString *)defaultName orDefault:(NSArray*)defaultValue
{
    NSArray * ret = [self arrayForKey:defaultName];
    if (!ret) return defaultValue;
    return ret;
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName orDefault:(NSDictionary*)defaultValue
{
    NSDictionary * ret = [self dictionaryForKey:defaultName];
    if (!ret) return defaultValue;
    return ret;
}

- (NSData *)dataForKey:(NSString *)defaultName orDefault:(NSData*)defaultValue
{
    NSData * ret = [self dataForKey:defaultName];
    if (!ret) return defaultValue;
    return ret;
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName orDefault:(NSArray*)defaultValue
{
    NSArray * ret = [self stringArrayForKey:defaultName];
    if (!ret) return defaultValue;
    return ret;  
}

- (NSInteger)integerForKey:(NSString *)defaultName orDefault:(NSInteger)defaultValue
{
    NSObject * obj = [self objectForKey:defaultName];
    if (!obj) return defaultValue;
    else
    {
        if ([obj isKindOfClass:[NSNumber class]])
        {
            return [((NSNumber*)obj) intValue];
        }
        else
        {
            return defaultValue;
        }
    }
}

- (float)floatForKey:(NSString *)defaultName orDefault:(float)defaultValue
{
    NSObject * obj = [self objectForKey:defaultName];
    if (!obj) return defaultValue;
    else
    {
        if ([obj isKindOfClass:[NSNumber class]])
        {
            return [((NSNumber*)obj) floatValue];
        }
        else
        {
            return defaultValue;
        }
    }
}

- (double)doubleForKey:(NSString *)defaultName orDefault:(double)defaultValue
{
    NSObject * obj = [self objectForKey:defaultName];
    if (!obj) return defaultValue;
    else
    {
        if ([obj isKindOfClass:[NSNumber class]])
        {
            return [((NSNumber*)obj) doubleValue];
        }
        else
        {
            return defaultValue;
        }
    }
}

- (BOOL)boolForKey:(NSString *)defaultName orDefault:(BOOL)defaultValue
{
    NSObject * obj = [self objectForKey:defaultName];
    if (!obj) return defaultValue;
    else
    {
        if ([obj isKindOfClass:[NSNumber class]])
        {
            return [((NSNumber*)obj) boolValue];
        }
        else
        {
            return defaultValue;
        }
    }
}


@end
