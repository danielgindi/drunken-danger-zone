//
//  DGImageLoaderView.m
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

#import "DGImageLoaderView.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_MAX_ASYNC_CONNECTIONS 8

@interface DGImageLoaderView ()
{
    BOOL _isDefaultLoaded;
    DGImageLoaderViewAnimationType _animationType;
    BOOL _waitingForDisplay, _waitingForDisplayWithAnimation;
    BOOL _hasImageLoaded;
    BOOL _nextUrlToLoadIsLocal;
    
    NSURL *_nextUrlToLoad;
    int _asyncOperationCounter;
    
    NSString *_tempFilePath;
    NSFileHandle *_fileWriteHandle;
}

@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLConnection *urlConnection;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *nextImageView;
@property (nonatomic, strong) UIImageView *oldImageView;
@property (nonatomic, strong) UIImage *nextImage;

@end

@implementation DGImageLoaderView

// Performance tweaks

static NSUInteger s_DGImageLoaderView_maxAsyncConnections = DEFAULT_MAX_ASYNC_CONNECTIONS;
static NSUInteger s_DGImageLoaderView_currentActiveConnections = 0;
static NSMutableArray *s_DGImageLoaderView_queuedConnectionsArray = nil;
static NSMutableArray *s_DGImageLoaderView_activeConnectionsArray = nil;

#pragma mark - Init

- (id)init 
{
    if ((self = [super init]))
	{
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self initialize];
    }
    return self;
}

- (void)initialize
{
    if (!s_DGImageLoaderView_queuedConnectionsArray)
    {
        s_DGImageLoaderView_queuedConnectionsArray = [[NSMutableArray alloc] init];
    }
    if (!s_DGImageLoaderView_activeConnectionsArray)
    {
        s_DGImageLoaderView_activeConnectionsArray = [[NSMutableArray alloc] init];
    }
    
    _delayActualLoadUntilDisplay = NO;
    _delayImageShowUntilDisplay = YES;
    _waitingForDisplay = NO;
    _waitingForDisplayWithAnimation = NO;
    _isDefaultLoaded = YES;
    _keepAspectRatio = YES;
    _animationDuration = 0.8;
    _asyncLoadImages = YES;
    _resizeImages = YES;
    _cropAnchor = DGImageLoaderViewCropAnchorCenterCenter;
    _detectScaleFromFileName = YES;
    _autoFindScaledUrlForFileUrls = YES;
    
    self.clipsToBounds = YES;
    
    if (self.defaultImage)
    {
        self.oldImageView = [[UIImageView alloc] initWithImage:self.defaultImage];
        self.oldImageView.contentMode = UIViewContentModeScaleToFill;
        self.oldImageView.frame = [self rectForImage:self.oldImageView.image];
        [self addSubview:self.oldImageView];
    }
}

- (void)dealloc
{
    [self closeAndRemoveTempFile];
}

- (void)closeAndRemoveTempFile
{
    if (_fileWriteHandle)
    {
        [_fileWriteHandle closeFile];
        _fileWriteHandle = nil;
    }
    if (_tempFilePath)
    {
        [[NSFileManager defaultManager] removeItemAtPath:_tempFilePath error:nil];
        _tempFilePath = nil;
    }
}


- (void)loadImageFromPath:(NSString *)path originalUrl:(NSURL *)originalURL forceAnimation:(BOOL)forceAnimation
{
    BOOL asyncLoadImages = _asyncLoadImages;
    int asyncIndex = ++_asyncOperationCounter;
    
    void (^loadBlock)() = ^
    {
        @autoreleasepool
        {
            // If current operation is irrelevant by the time we got here...
            if (asyncIndex != _asyncOperationCounter) return;
            
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            
            // If current operation is irrelevant by the time we finished loading the image from file
            if (asyncIndex != _asyncOperationCounter) return;
            
            self.nextImage = image;
            if (image)
            {
                BOOL loadedThumbFromFile = YES;
                if (_resizeImages)
                {
                    image = [self imageThumbnailOfImage:image fromCacheOfURL:originalURL isFromFile:&loadedThumbFromFile];
                    
                    // If current operation is irrelevant by the time we finished thumbnailing the image from file
                    if (asyncIndex != _asyncOperationCounter) return;
                }
                
                if (_tempFilePath)
                {
                    [[NSFileManager defaultManager] moveItemAtPath:_tempFilePath toPath:[self getLocalCachePathForUrl:originalURL] error:nil];
                }
                
                self.nextImage = image;
                
                BOOL animate = forceAnimation || !_doNotAnimateFromCache || !loadedThumbFromFile;
                void (^playBlock)() = ^
                {
                    // If current operation is irrelevant by the time we made it to the main queue
                    if (asyncIndex != _asyncOperationCounter) return;
                    [self playWithAnimation:animate immediate:NO];
                };
                
                if (asyncLoadImages)
                { // Return to main queue for UI operations
                    dispatch_async(dispatch_get_main_queue(), playBlock);
                }
                else
                { // Go on, we are on the main thread already
                    playBlock();
                }
            }
            
        } // @autoreleasepool
        
    };
    
    if (asyncLoadImages)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), loadBlock);
    }
    else
    {
        loadBlock();
    }
}

#pragma mark - UIView

- (void)layoutSubviews
{
    if (self.oldImageView)
    {
        self.oldImageView.frame = [self rectForImage:self.oldImageView.image];
    }
    if (self.nextImageView)
    {
        self.nextImageView.frame = [self rectForImage:self.nextImageView.image];
    }
    if (self.indicator)
    {
        CGRect rc = self.indicator.frame;
        rc.origin.x = (self.frame.size.width - rc.size.width) / 2.f;
        rc.origin.y = (self.frame.size.height - rc.size.height) / 2.f;
        self.indicator.frame = rc;
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_waitingForDisplay)
    { // Image is present, we are just waiting for this moment to start animating it, when the view came into view...
        _waitingForDisplay = NO;
        [self playWithAnimation:_waitingForDisplayWithAnimation immediate:YES];
    }
    
    if (_nextUrlToLoad)
    { // We are waiting for this moment to start loading the image, when the view came into view...
        [self loadImageFromURL:_nextUrlToLoad andAnimationType:_animationType immediate:YES isLocalUrl:_nextUrlToLoadIsLocal];
        _nextUrlToLoad = nil;
        _nextUrlToLoadIsLocal = NO;
    }
}

#pragma mark - Utilities

- (CGRect)rectForImage:(UIImage *)image
{
    float scale = image.scale / UIScreen.mainScreen.scale;
    return [self rectForWidth:image.size.width * scale
                     andHeight:image.size.height * scale
               keepAspectRatio:_keepAspectRatio
                fitFromOutside:_fitFromOutside
                    cropAnchor:_cropAnchor];
}

+ (CGRect)rectForWidth:(CGFloat)cx
             andHeight:(CGFloat)cy
               inFrame:(CGRect)parentBox
       keepAspectRatio:(BOOL)keepAspectRatio
        fitFromOutside:(BOOL)fitFromOutside
            cropAnchor:(DGImageLoaderViewCropAnchor)cropAnchor
{
    CGRect box = parentBox;
    if (keepAspectRatio)
    {
        CGFloat ratio = cy == 0 ? 1 : (cx / cy);
        CGFloat newRatio = parentBox.size.height == 0 ? 1 : (parentBox.size.width / parentBox.size.height);
        
        if ((newRatio > ratio && !fitFromOutside) ||
            (newRatio < ratio && fitFromOutside))
        {
            box.size.height = parentBox.size.height;
            box.size.width = box.size.height * ratio;
        }
        else if ((newRatio > ratio && fitFromOutside) ||
                 (newRatio < ratio && !fitFromOutside))
        {
            box.size.width = parentBox.size.width;
            box.size.height = box.size.width / ratio;
        }
        else
        {
            box.size.width = parentBox.size.width;
            box.size.height = parentBox.size.height;
        }
        
        if (fitFromOutside)
        {
            switch (cropAnchor)
            {
                default:
                case DGImageLoaderViewCropAnchorCenterCenter:
                    box.origin.x = (parentBox.size.width - box.size.width) / 2.f;
                    box.origin.y = (parentBox.size.height - box.size.height) / 2.f;
                    break;
                case DGImageLoaderViewCropAnchorCenterLeft:
                    box.origin.x = 0.f;
                    box.origin.y = (parentBox.size.height - box.size.height) / 2.f;
                    break;
                case DGImageLoaderViewCropAnchorCenterRight:
                    box.origin.x = parentBox.size.width - box.size.width;
                    box.origin.y = (parentBox.size.height - box.size.height) / 2.f;
                    break;
                case DGImageLoaderViewCropAnchorTopCenter:
                    box.origin.x = (parentBox.size.width - box.size.width) / 2.f;
                    box.origin.y = 0.f;
                    break;
                case DGImageLoaderViewCropAnchorTopLeft:
                    box.origin.x = 0.f;
                    box.origin.y = 0.f;
                    break;
                case DGImageLoaderViewCropAnchorTopRight:
                    box.origin.x = parentBox.size.width - box.size.width;
                    box.origin.y = 0.f;
                    break;
                case DGImageLoaderViewCropAnchorBottomCenter:
                    box.origin.x = (parentBox.size.width - box.size.width) / 2.f;
                    box.origin.y = parentBox.size.height - box.size.height;
                    break;
                case DGImageLoaderViewCropAnchorBottomLeft:
                    box.origin.x = 0.f;
                    box.origin.y = parentBox.size.height - box.size.height;
                    break;
                case DGImageLoaderViewCropAnchorBottomRight:
                    box.origin.x = parentBox.size.width - box.size.width;
                    box.origin.y = parentBox.size.height - box.size.height;
                    break;
            }
        }
        else
        {
            box.origin.x = (parentBox.size.width - box.size.width) / 2.f;
            box.origin.y = (parentBox.size.height - box.size.height) / 2.f;
        }
    }
    else
    {
        box.origin.x = 0.f;
        box.origin.y = 0.f;
    }
    
    box.origin.x += parentBox.origin.x;
    box.origin.y += parentBox.origin.y;
    
    return box;
}

- (CGRect)rectForWidth:(CGFloat)cx
              andHeight:(CGFloat)cy
        keepAspectRatio:(BOOL)keepAspectRatio
         fitFromOutside:(BOOL)fitFromOutside
             cropAnchor:(DGImageLoaderViewCropAnchor)cropAnchor
{
    return [DGImageLoaderView rectForWidth:cx andHeight:cy inFrame:self.bounds keepAspectRatio:keepAspectRatio fitFromOutside:fitFromOutside cropAnchor:cropAnchor];
}

- (UIImage *)imageByScalingImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString *)newTempFilePath
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"image-loader-%@", uuidStr]];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return path;
}

- (NSFileHandle *)fileHandleToANewTempFile:(out NSString **)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempFilePath = self.newTempFilePath;
    int tries = 3;
    BOOL success = [fileManager createFileAtPath:tempFilePath contents:nil attributes:nil];
    while (!success && --tries)
    {
        tempFilePath = self.newTempFilePath;
        success = [fileManager createFileAtPath:tempFilePath contents:nil attributes:nil];
    }
    
    if (success)
    {
        if (filePath)
        {
            *filePath = tempFilePath;
        }
        return [NSFileHandle fileHandleForWritingAtPath:tempFilePath];
    }
    
    return nil;
}

- (NSURL *)normalizedUrlForUrl:(NSURL *)url
{
    if (_autoFindScaledUrlForFileUrls && url.isFileURL)
    {
        if (UIScreen.mainScreen.scale == 2.f && ![[[url lastPathComponent] stringByDeletingPathExtension] hasSuffix:@"@2x"])
        {
            NSString *path = [[url path] stringByDeletingPathExtension];
            path = [path stringByAppendingString:@"@2x"];
            if (url.pathExtension.length || [[url lastPathComponent] hasSuffix:@"."])
            {
                path = [path stringByAppendingPathExtension:url.pathExtension];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                return [[NSURL alloc] initFileURLWithPath:path];
            }
        }
    }
    return url;
}

#pragma mark - Caching stuff

- (NSString *)getLocalCachePathForUrl:(NSURL *)url
{
    if (!url) return nil; // Silence Xcode's Analyzer
    
    // an alternative to the NSTemporaryDirectory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = paths.count ? paths[0] : [NSHomeDirectory() stringByAppendingString:@"/Library/Caches"];
    path = [path stringByAppendingPathComponent:@"dg-image-loader"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Can't create cache folder, error: %@", error);
            return nil;
        }
    }
    
    const char *urlStr = url.absoluteString.UTF8String;
    unsigned char md5result[16];
    CC_MD5(urlStr, (CC_LONG)strlen(urlStr), md5result); // This is the md5 call
    path = [path stringByAppendingPathComponent:
            [NSString stringWithFormat:
             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             md5result[0], md5result[1], md5result[2], md5result[3],
             md5result[4], md5result[5], md5result[6], md5result[7],
             md5result[8], md5result[9], md5result[10], md5result[11],
             md5result[12], md5result[13], md5result[14], md5result[15]
             ]];
    
    NSString *fn = url.lastPathComponent.lowercaseString;
    
    BOOL doubleScale = _detectScaleFromFileName ? [[fn stringByDeletingPathExtension] hasSuffix:@"@2x"] : (UIScreen.mainScreen.scale == 2.f);
    
    if (doubleScale)
    {
        path = [path stringByAppendingString:@"@2x"];
    }
    
    if (fn.pathExtension.length)
    {
        path = [path stringByAppendingPathExtension:fn.pathExtension];
    }
    
    return path;
}

- (NSString *)getLocalCachePathForUrl:(NSURL *)url withThumbnailSize:(CGSize)thumbnailSize
{
    // an alternative to the NSTemporaryDirectory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = paths.count ? paths[0] : [NSHomeDirectory() stringByAppendingString:@"/Library/Caches"];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"dg-image-loader/Thumbnail%f,%f", thumbnailSize.width, thumbnailSize.height]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Can't create cache folder, error: %@", error);
            return nil;
        }
    }
    
    const char *urlStr = url.absoluteString.UTF8String;
    unsigned char md5result[16];
    CC_MD5(urlStr, (CC_LONG)strlen(urlStr), md5result);
    path = [path stringByAppendingPathComponent:
            [NSString stringWithFormat:
             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             md5result[0], md5result[1], md5result[2], md5result[3],
             md5result[4], md5result[5], md5result[6], md5result[7],
             md5result[8], md5result[9], md5result[10], md5result[11],
             md5result[12], md5result[13], md5result[14], md5result[15]
             ]];
    
    NSString *fn = url.lastPathComponent.lowercaseString;
    
    path = [path stringByAppendingString:@"@2x"];
    
    if (fn.pathExtension.length)
    {
        path = [path stringByAppendingPathExtension:fn.pathExtension];
    }
    
    return path;
}

- (UIImage *)imageThumbnailOfImage:(UIImage *)image fromCacheOfURL:(NSURL *)url isFromFile:(BOOL *)fromFile
{
    CGSize neededSize = [self rectForImage:image].size;
    
    CGSize currentSize = image.size;
    float scale = image.scale / UIScreen.mainScreen.scale;
    currentSize.width *= scale;
    currentSize.height *= scale;
    
    if (fromFile)
    {
        *fromFile = YES;
    }
    
    if (neededSize.width != currentSize.width ||
        neededSize.height != currentSize.height)
    {
        neededSize.width = roundf(neededSize.width);
        neededSize.height = roundf(neededSize.height);
        
        NSString *thumbCachePath = url ? [self getLocalCachePathForUrl:url withThumbnailSize:neededSize] : nil;
        
        if (thumbCachePath)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:thumbCachePath])
            {
                image = [UIImage imageWithContentsOfFile:thumbCachePath];
            }
            else
            {
                if (fromFile) *fromFile = NO;
                image = [self imageByScalingImage:image toSize:neededSize];
                [UIImageJPEGRepresentation(image, 1.f) writeToFile:thumbCachePath options:NSDataWritingAtomic error:nil];
            }
        }
        else
        {
            if (fromFile) *fromFile = NO;
            image = [self imageByScalingImage:image toSize:neededSize];
        }
    }
    return image;
}

#pragma mark - Accessors

- (void)setDefaultImage:(UIImage *)defaultImage
{
    _defaultImage = defaultImage;
    if (_isDefaultLoaded)
    {
        if (self.oldImageView)
        {
            if (_defaultImage)
            {
                self.oldImageView.image = defaultImage;
                self.oldImageView.frame = [self rectForImage:self.oldImageView.image];
            }
            else
            {
                [self.oldImageView removeFromSuperview];
                self.oldImageView = nil;
            }
        }
        else
        {
            if (defaultImage)
            {
                self.oldImageView = [[UIImageView alloc] initWithImage:_defaultImage];
                self.oldImageView.contentMode = UIViewContentModeScaleToFill;
                self.oldImageView.frame = [self rectForImage:self.oldImageView.image];
                [self addSubview:self.oldImageView];
            }
        }
    }
}

- (UIImage *)currentVisibleImage
{
    return self.oldImageView.image;
}

- (UIImage *)currentVisibleImageNotDefault
{
    UIImage *result = self.oldImageView.image;
    if (result == self.defaultImage)
    {
        result = nil;
    }
    return result;
}

- (BOOL)hasImageLoaded
{
    return _hasImageLoaded;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([response respondsToSelector:@selector(statusCode)])
	{
		NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];
		if (statusCode != 200)
		{
			[self connection:connection didFailWithError:nil];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData 
{
    if (!_fileWriteHandle)
	{
        NSString *filePath;
        _fileWriteHandle = [self fileHandleToANewTempFile:&filePath];
        _tempFilePath = filePath;
    }
    [_fileWriteHandle writeData:incrementalData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopAndRemoveConnection];
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (_fileWriteHandle)
	{
        [self stopAndRemoveConnection];
        [_fileWriteHandle closeFile];
        _fileWriteHandle = nil;
        
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
        
        [self loadImageFromPath:_tempFilePath originalUrl:_urlRequest.URL forceAnimation:YES];
	}
    else
    {
        [self connection:connection didFailWithError:nil];
    }
}

#pragma mark - Public methods

- (void)loadImageFromURL:(NSURL *)url andAnimationType:(DGImageLoaderViewAnimationType)animationType
{
    [self loadImageFromURL:url andAnimationType:animationType immediate:NO isLocalUrl:NO];
}

- (void)loadImageFromURL:(NSURL *)url andAnimationType:(DGImageLoaderViewAnimationType)animationType immediate:(BOOL)immediate isLocalUrl:(BOOL)isLocalUrl
{
    url = [self normalizedUrlForUrl:url];
    
    _animationType = animationType;
    
    // If we need to delay loading until the view is actually displayed, and it hasn't yet, then:
    if (_delayActualLoadUntilDisplay && !immediate)
    {
        _nextUrlToLoad = url;
        _nextUrlToLoadIsLocal = isLocalUrl;
        [self setNeedsDisplay]; // Cause drawRect: to be called when coming on-screen
        return;
    }
    
    NSString *cachePath = isLocalUrl ? nil : (url ? [self getLocalCachePathForUrl:url] : nil);
    
    if (!url || isLocalUrl || [[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [self loadImageFromPath:(isLocalUrl ? url.path : cachePath) originalUrl:url forceAnimation:NO];
    }
    else
    {
        if (!self.indicator)
        {
            self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            CGRect rc = self.indicator.frame;
            rc.origin.x = (self.frame.size.width - rc.size.width) / 2.f;
            rc.origin.y = (self.frame.size.height - rc.size.height) / 2.f;
            self.indicator.frame = rc;
            [self addSubview:self.indicator];
        }
        else
        {
            self.indicator.hidden = NO;
            [self bringSubviewToFront:self.indicator];
        }
        [self.indicator startAnimating];
        
        if (self.urlConnection)
        {
            [self stopAndRemoveConnection];
        }
        [self closeAndRemoveTempFile];
        
        self.urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self startImmediately:NO];
        
        @synchronized(s_DGImageLoaderView_queuedConnectionsArray)
        {
            [s_DGImageLoaderView_queuedConnectionsArray addObject:self.urlConnection];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^(void){
                [DGImageLoaderView continueConnectionQueue];
            });
        }
    }
}

- (void)loadImageFromLocalURL:(NSURL *)url andAnimationType:(DGImageLoaderViewAnimationType)animationType
{
    [self loadImageFromURL:url andAnimationType:animationType immediate:NO isLocalUrl:YES];
}

- (void)loadImage:(UIImage *)image withAnimationType:(DGImageLoaderViewAnimationType)animationType
{
    if (!image)
    {
        [self reset];
    }
    else
    {
        [self stopAndRemoveConnection];
        
        BOOL asyncLoadImages = _asyncLoadImages;
        int asyncIndex = ++_asyncOperationCounter;
        void(^loadBlock)() = ^
        {
            // If current operation is irrelevant by the time we got here...
            if (asyncIndex != _asyncOperationCounter) return;
            
            UIImage *actualImage = image;
            if (_resizeImages)
            {
                actualImage = [self imageThumbnailOfImage:actualImage fromCacheOfURL:nil isFromFile:NULL];
                
                // If current operation is irrelevant by the time we finished thumbnailing the image from file
                if (asyncIndex != _asyncOperationCounter) return;
            }
            
            self.nextImage = actualImage;
            
            BOOL animate = !_doNotAnimateFromCache;
            void(^playBlock)() = ^
            {
                // If current operation is irrelevant by the time we made it to the main queue
                if (asyncIndex != _asyncOperationCounter) return;
                [self playWithAnimation:animate immediate:NO];
            };
            
            if (asyncLoadImages)
            { // Return to main queue for UI operations
                dispatch_async(dispatch_get_main_queue(), playBlock);
            }
            else
            { // Go on, we are on the main thread already
                playBlock();
            }
        };
        
        if (asyncLoadImages)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), loadBlock);
        }
        else
        {
            loadBlock();
        }
    }
}

- (void)stop
{
    [self stopAndRemoveConnection];
    [self closeAndRemoveTempFile];
    _waitingForDisplay = NO;
}

- (void)reset
{
	[self stop];
    
    if (self.oldImageView)
    {
        [self.oldImageView removeFromSuperview];
        self.oldImageView = nil;
    }
    
    if (self.nextImageView)
    {
        [self.nextImageView removeFromSuperview];
        self.nextImageView = nil;
    }
    
    if (self.defaultImage)
    {
        self.oldImageView = [[UIImageView alloc] initWithImage:self.defaultImage];
        self.oldImageView.contentMode = UIViewContentModeScaleToFill;
        self.oldImageView.frame = [self rectForImage:self.oldImageView.image];
        [self addSubview:self.oldImageView];
    }
    
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    
    _hasImageLoaded = NO;
    _isDefaultLoaded = YES;
    
    _nextUrlToLoadIsLocal = NO;
    _nextUrlToLoad = nil;
    
    _waitingForDisplayWithAnimation = NO;
    _waitingForDisplay = NO;
}

#pragma mark - Animation stuff

- (void)playWithAnimation:(BOOL)withAnimation immediate:(BOOL)immediate
{
    if (self.nextImage)
    {
        _hasImageLoaded = YES;
    }
    
    // Default next image if needed
    if (!self.nextImage || (self.nextImage.size.width <= 1 && self.nextImage.size.height <= 1))
    {
        self.nextImage = self.defaultImage;
        _hasImageLoaded = NO;
    }
    
    // If we need to delay loading until the view is actually displayed, and it hasn't yet and also its not the default image which is already loaded to memory, then:
    if ((_delayActualLoadUntilDisplay || _delayImageShowUntilDisplay) && !immediate && self.nextImage != self.defaultImage)
    {
        _waitingForDisplay = YES;
        _waitingForDisplayWithAnimation = withAnimation;
        [self setNeedsDisplay]; // Cause drawRect: to be called when coming on-screen
        return;
    }
    
    // Clear animation type if the [withAnimation] argument is not set
    DGImageLoaderViewAnimationType animationType = withAnimation?_animationType:DGImageLoaderViewAnimationTypeNone;
    
    // Prepare next image view for animation
    self.nextImageView = [[UIImageView alloc] initWithImage:self.nextImage];
    self.nextImageView.contentMode = UIViewContentModeScaleToFill;
    self.nextImageView.frame = [self rectForImage:self.nextImageView.image];
    
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    self.nextImage = nil;
    
    // Switch image views with or without animation
    switch (animationType)
    {
        default:
        case DGImageLoaderViewAnimationTypeNone:
        {
            [self addSubview:self.nextImageView];
            [self.oldImageView removeFromSuperview];
            self.oldImageView = self.nextImageView;
            self.nextImageView = nil;
        }
            break;
        case DGImageLoaderViewAnimationTypeFade:
        {
            self.nextImageView.alpha = 0;
            [self addSubview:self.nextImageView];
            [UIView animateWithDuration:_animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.nextImageView.alpha = 1;
                self.oldImageView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.oldImageView removeFromSuperview];
                self.oldImageView = self.nextImageView;
                self.nextImageView = nil;
            }];
        }
            break;
    }
}

#pragma mark - Connection control

+ (NSUInteger)maxAsyncConnections
{
    return s_DGImageLoaderView_maxAsyncConnections;
}

+ (void)setMaxAsyncConnections:(NSUInteger)max
{
    @synchronized(s_DGImageLoaderView_queuedConnectionsArray)
    {
        s_DGImageLoaderView_maxAsyncConnections = max;
    }
    [DGImageLoaderView continueConnectionQueue];
}

+ (NSUInteger)activeConnections
{
    return s_DGImageLoaderView_currentActiveConnections;
}

+ (NSUInteger)totalConnections
{
    @synchronized(s_DGImageLoaderView_queuedConnectionsArray)
    {
        return s_DGImageLoaderView_activeConnectionsArray.count + s_DGImageLoaderView_queuedConnectionsArray.count;
    }
}

- (void)stopAndRemoveConnection
{
    if (!self.urlConnection) return;
    [self.urlConnection cancel];
    @synchronized(s_DGImageLoaderView_queuedConnectionsArray)
    {
        if ([s_DGImageLoaderView_activeConnectionsArray containsObject:self.urlConnection])
        {
            [s_DGImageLoaderView_activeConnectionsArray removeObject:self.urlConnection];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^(void) {
                [DGImageLoaderView continueConnectionQueue];
            });
        }
        else if ([s_DGImageLoaderView_queuedConnectionsArray containsObject:self.urlConnection])
        {
            [s_DGImageLoaderView_queuedConnectionsArray removeObject:self.urlConnection];
        }
    }
    self.urlConnection = nil;
}

+ (void)continueConnectionQueue
{
    @synchronized(s_DGImageLoaderView_queuedConnectionsArray)
    {
        if (s_DGImageLoaderView_queuedConnectionsArray.count && s_DGImageLoaderView_activeConnectionsArray.count < s_DGImageLoaderView_maxAsyncConnections)
        {
            NSURLConnection *connection = [s_DGImageLoaderView_queuedConnectionsArray objectAtIndex:0];
            [s_DGImageLoaderView_queuedConnectionsArray removeObject:connection];
            [s_DGImageLoaderView_activeConnectionsArray addObject:connection];
            [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [connection start];
        }
    }
}

@end
