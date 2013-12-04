//
//  DGITunesSearchApiRequest.h
//  DGITunesSearchApi
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <Foundation/Foundation.h>

typedef void (^DGITunesSearchApiRequestJsonResponseBlock)(NSObject *response);
typedef void (^DGITunesSearchApiRequestErrorBlock)(NSError *error);

@interface DGITunesSearchApiRequest : NSObject

- (id)initWithUrl:(NSURL *)url completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock;
- (id)initWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock;
- (id)initWithUrl:(NSURL *)url timeout:(NSTimeInterval)timeout completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock;
- (id)initWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeout:(NSTimeInterval)timeout completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock;
- (DGITunesSearchApiRequest *)start;
- (DGITunesSearchApiRequest *)cancel;
+ (DGITunesSearchApiRequest *)requestWithUrl:(NSURL *)url completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock start:(BOOL)start;
+ (DGITunesSearchApiRequest *)requestWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock start:(BOOL)start;
+ (DGITunesSearchApiRequest *)requestWithUrl:(NSURL *)url timeout:(NSTimeInterval)timeout completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock start:(BOOL)start;
+ (DGITunesSearchApiRequest *)requestWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeout:(NSTimeInterval)timeout completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock start:(BOOL)start;

+ (NSString *)urlEncodedString:(NSString *)component;

@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy)   DGITunesSearchApiRequestJsonResponseBlock completionBlock;
@property (nonatomic, copy)   DGITunesSearchApiRequestErrorBlock errorBlock;

@end
