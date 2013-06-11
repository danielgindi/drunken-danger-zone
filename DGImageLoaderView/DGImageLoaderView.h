//
//  DGImageLoaderView.h
//  DGImageLoaderView
//
//  Created by Daniel Cohen Gindi on 01/03/2012.
//  Copyright (c) 2011 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <UIKit/UIKit.h>

typedef enum _DGImageLoaderViewAnimationType
{
	DGImageLoaderViewAnimationTypeNone = 0,
	DGImageLoaderViewAnimationTypeFade = 1
} DGImageLoaderViewAnimationType;

typedef enum _DGImageLoaderViewCropAnchor
{
	DGImageLoaderViewCropAnchorCenterCenter,
	DGImageLoaderViewCropAnchorCenterLeft,
	DGImageLoaderViewCropAnchorCenterRight,
	DGImageLoaderViewCropAnchorTopCenter,
	DGImageLoaderViewCropAnchorTopLeft,
    DGImageLoaderViewCropAnchorTopRight,
    DGImageLoaderViewCropAnchorBottomCenter,
    DGImageLoaderViewCropAnchorBottomLeft,
    DGImageLoaderViewCropAnchorBottomRight
} DGImageLoaderViewCropAnchor;

@interface DGImageLoaderView : UIView <NSURLConnectionDelegate>

@property (nonatomic, assign, readonly) BOOL hasImageLoaded;
@property (nonatomic, strong) UIImage * defaultImage;
@property (nonatomic, assign) BOOL keepAspectRatio;
@property (nonatomic, assign) BOOL fitFromOutside;
@property (nonatomic, assign) DGImageLoaderViewCropAnchor cropAnchor;
@property (nonatomic, assign) float animationDuration;
@property (nonatomic, strong, readonly) UIImage * currentVisibleImage;
@property (nonatomic, strong, readonly) UIImage * currentVisibleImageNotDefault;

// Performance tweaks
@property (nonatomic, assign) BOOL doNotAnimateFromCache; // Will not animate when loaded completely from cache
@property (nonatomic, assign) BOOL delayActualLoadUntilDisplay; // Delay heavy loading (like network work) to the first time that drawRect: is requested
@property (nonatomic, assign) BOOL delayImageShowUntilDisplay; // Delay actual showing (animation) to the first time that drawRect: is requested
@property (nonatomic, assign) BOOL asyncLoadImages; // Do image loading on separate queue
@property (nonatomic, assign) BOOL resizeImagesToNeededSize; // Post process images to resize to requested size

- (void)loadImageFromURL:(NSURL*)url andAnimationType:(DGImageLoaderViewAnimationType)animationType;
- (void)loadImageFromURL:(NSURL*)url andAnimationType:(DGImageLoaderViewAnimationType)animationType immediate:(BOOL)immediate isLocalUrl:(BOOL)localUrl;
- (void)loadImage:(UIImage*)image withAnimationType:(DGImageLoaderViewAnimationType)animationType;
- (void)stop;
- (void)reset;

+ (int)maxAsyncConnections;
+ (void)setMaxAsyncConnections:(int)max;
+ (int)activeConnections;
+ (int)totalConnections;

@end
