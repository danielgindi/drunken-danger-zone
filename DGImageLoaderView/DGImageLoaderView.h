//
//  DGImageLoaderView.h
//  DGImageLoaderView
//
//  Created by Daniel Cohen Gindi on 01/03/2012.
//  Copyright (c) 2011 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
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

/*! @property hasImageLoaded
    @brief Do we have an image loaded? */
@property (nonatomic, assign, readonly) BOOL hasImageLoaded;

/*! @property defaultImage
    @brief Default image to use when not loaded or after calling reset
    Default: nil
 */
@property (nonatomic, strong) UIImage *defaultImage;

/*! @property keepAspectRatio
    @brief Should we keep the aspect ration when resizing the image?
    Default: YES
 */
@property (nonatomic, assign) BOOL keepAspectRatio;

/*! @property fitFromOutside
    @brief Should we fit the image from ouside of the bounds of the UIView, so there are not blanks inside?
    Default: NO
 */
@property (nonatomic, assign) BOOL fitFromOutside;

/*! @property cropAnchor
    @brief If fitFromOutside is set, this property determines which part you want to be most visible in the image. Or more precisely, which part of the image you want to "crop" to the required size.
    Default: DGImageLoaderViewCropAnchorCenterCenter
 */
@property (nonatomic, assign) DGImageLoaderViewCropAnchor cropAnchor;

/*! @property animationDuration
    @brief The duration of the animation (if there's an animation chosen for displaying the image). Specified in seconds.
    Default: 0.8
 */
@property (nonatomic, assign) float animationDuration;

/*! @property currentVisibleImage
    @brief The currently loaded image, including the default image if loaded. */
@property (nonatomic, strong, readonly) UIImage *currentVisibleImage;

/*! @property currentVisibleImageNotDefault
    @brief The currently loaded image, but returning nil if the default image is loaded */
@property (nonatomic, strong, readonly) UIImage *currentVisibleImageNotDefault;

/*! @property doNotAnimateFromCache
    @brief Will not animate when loaded completely from cache, and no extra work has to be done.
    Default: NO */
@property (nonatomic, assign) BOOL doNotAnimateFromCache;

/*! @property delayActualLoadUntilDisplay
    @brief Delay the loading from network to the first time that drawRect: is requested.
    This is useful for example when you have a circular gallery with 20 images and you want the first image to load fast, and the others to load only if the user scrolls to them, so you gain good UX and you do not use extra bandwidth that is not needed.
    Default: NO */
@property (nonatomic, assign) BOOL delayActualLoadUntilDisplay;

/*! @property delayImageShowUntilDisplay
    @brief Delay actual showing (or animation) to the first time that drawRect: is requested.
    This prevents extra work for when you have many off-screen images.
    This also causes the Fade animation, if chosen, to always be visible and not happen when off-screen, so you can always achieve that nice effect.
    Default: YES */
@property (nonatomic, assign) BOOL delayImageShowUntilDisplay;

/*! @property asyncLoadImages
    @brief Do the image loading (reading or writing to cached files) on a separate queue.
    Default: YES */
@property (nonatomic, assign) BOOL asyncLoadImages;

/*! @property resizeImages
    @brief Post process images to resize to requested size.
    Disable this if images are known to always come in the correct size.
    Default: YES */
@property (nonatomic, assign) BOOL resizeImages;

/*! @property detectScaleFromFileName
    @brief Set this to YES if you want to specify urls that contain the @2x for scale. Otherwise, scale will be set according to current screen.
    Default: YES */
@property (nonatomic, assign) BOOL detectScaleFromFileName;

/*! Load the image from an URL
    @param url  The URL of the image to load
    @param animationType  The kind of animation to use when displaying the image. */
- (void)loadImageFromURL:(NSURL *)url andAnimationType:(DGImageLoaderViewAnimationType)animationType;

/*! Load the image from an URL
    @param url  The URL of the image to load
    @param animationType  The kind of animation to use when displaying the image.
    @param immediate  If set to YES, will override any delaying of loading or displaying, and will immediately load and display the image. 
    @param isLocalUrl Tells it that the URL is of a local file, which should NOT be cached, as it exists locally already */
- (void)loadImageFromURL:(NSURL *)url andAnimationType:(DGImageLoaderViewAnimationType)animationType immediate:(BOOL)immediate isLocalUrl:(BOOL)isLocalUrl;

/*! Load the image from a local URL
 @param url  The URL of the image to load
 @param animationType  The kind of animation to use when displaying the image. */
- (void)loadImageFromLocalURL:(NSURL *)url andAnimationType:(DGImageLoaderViewAnimationType)animationType;

/*! Load the image from an UIImage
    This is useful when you want to use the "resize" feature on an available UIImage
    @param animationType  The kind of animation to use when displaying the image. */
- (void)loadImage:(UIImage *)image withAnimationType:(DGImageLoaderViewAnimationType)animationType;

/*! Stops any loading of image in progress */
- (void)stop;

/*! Stops any loading of image in progress, and resets to the defaultImage if present */
- (void)reset;

/*! Maximum asynchronous connections that can be used to load images. 
    This affects this class overall in the app.
    The default is 8.
    @return The max connections */
+ (int)maxAsyncConnections;

/*! Maximum asynchronous connections that can be used to load images
    @param int The max connections */
+ (void)setMaxAsyncConnections:(int)max;

/*! Current active connections used by this class overall in the app
    @param int The active connections count */
+ (int)activeConnections;

/*! Total connections which include active + pending connections, used by this class overall in the app
    @param int The total connections count */
+ (int)totalConnections;

@end
