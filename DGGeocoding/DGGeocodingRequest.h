//
//  DGGeocodingRequest.h
//  DGGeocoding
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <Foundation/Foundation.h>

typedef void (^DGGeocodingRequestJsonResponseBlock)(NSObject *response);
typedef void (^DGGeocodingRequestErrorBlock)(NSError *error);

@interface DGGeocodingRequest : NSObject

- (id)initWithUrl:(NSURL *)url completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock;
- (id)initWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock;
- (id)initWithUrl:(NSURL *)url timeout:(NSTimeInterval)timeout completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock;
- (id)initWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeout:(NSTimeInterval)timeout completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock;
- (DGGeocodingRequest *)start;
- (DGGeocodingRequest *)cancel;
+ (DGGeocodingRequest *)requestWithUrl:(NSURL *)url completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock start:(BOOL)start;
+ (DGGeocodingRequest *)requestWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock start:(BOOL)start;
+ (DGGeocodingRequest *)requestWithUrl:(NSURL *)url timeout:(NSTimeInterval)timeout completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock start:(BOOL)start;
+ (DGGeocodingRequest *)requestWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeout:(NSTimeInterval)timeout completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock start:(BOOL)start;

+ (NSString *)urlEncodedString:(NSString *)component;

@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy)   DGGeocodingRequestJsonResponseBlock completionBlock;
@property (nonatomic, copy)   DGGeocodingRequestErrorBlock errorBlock;

@end
