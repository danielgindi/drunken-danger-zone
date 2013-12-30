//
//  NSUserDefaults+DefaultValues.h
//  Additions
//
//  Created by Daniel Cohen Gindi on 6/2/11.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (DefaultValues)

- (NSString *)stringForKey:(NSString *)defaultName orDefault:(NSString*)defaultValue;
- (NSArray *)arrayForKey:(NSString *)defaultName orDefault:(NSArray*)defaultValue;
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName orDefault:(NSDictionary*)defaultValue;
- (NSData *)dataForKey:(NSString *)defaultName orDefault:(NSData*)defaultValue;
- (NSArray *)stringArrayForKey:(NSString *)defaultName orDefault:(NSArray*)defaultValue;
- (NSInteger)integerForKey:(NSString *)defaultName orDefault:(NSInteger)defaultValue;
- (float)floatForKey:(NSString *)defaultName orDefault:(float)defaultValue;
- (double)doubleForKey:(NSString *)defaultName orDefault:(double)defaultValue;
- (BOOL)boolForKey:(NSString *)defaultName orDefault:(BOOL)defaultValue;

@end
