//
//  DGImageLoaderView.m
//  DGImageLoaderView
//
//  Created by Daniel Cohen Gindi on 01/03/2012.
//  Copyright (c) 2011 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGImageLoaderView.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_MAX_ASYNC_CONNECTIONS 8

@interface DGImageLoaderView ()
{
    BOOL isDefaultLoaded;
    DGImageLoaderViewAnimationType _animationType;
    BOOL waitingForDisplay, waitingForDisplayWithAnimation;
    BOOL _hasImageLoaded;
    BOOL nextUrlToLoadIsLocal;
    
    NSURL * nextUrlToLoad;
    int asyncOperationCounter;
}

@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *connectionData;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *nextImageView;
@property (nonatomic, strong) UIImageView *oldImageView;
@property (nonatomic, strong) UIImage *nextImage;

@end

@implementation DGImageLoaderView

// Performance tweaks

static int s_DGImageLoaderView_maxAsyncConnections = DEFAULT_MAX_ASYNC_CONNECTIONS;
static int s_DGImageLoaderView_currentActiveConnections = 0;
static NSMutableArray * s_DGImageLoaderView_queuedConnectionsArray = nil;
static NSMutableArray * s_DGImageLoaderView_activeConnectionsArray = nil;

#pragma mark - Init

- (id)init 
{
    if ((self=[super init])) 
	{
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self=[super initWithCoder:aDecoder])) 
	{
		[self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame]))
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
    waitingForDisplay = waitingForDisplayWithAnimation = NO;
    isDefaultLoaded = YES;
    _keepAspectRatio = YES;
    _animationDuration = 0.8;
    self.clipsToBounds = YES;
    if (self.defaultImage)
    {
        self.oldImageView = [[UIImageView alloc] initWithImage:self.defaultImage];
        self.oldImageView.contentMode = UIViewContentModeScaleToFill;
        self.oldImageView.frame = [self calculateFrameForImage:self.oldImageView.image];
        [self addSubview:self.oldImageView];
    }
}

#pragma mark - UIView

- (void)layoutSubviews
{
    if (self.oldImageView)
    {
        self.oldImageView.frame = [self calculateFrameForImage:self.oldImageView.image];
    }
    if (self.nextImageView)
    {
        self.nextImageView.frame = [self calculateFrameForImage:self.nextImageView.image];
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
    if (waitingForDisplay)
    {
        waitingForDisplay = NO;
        [self playWithAnimation:waitingForDisplayWithAnimation immediate:YES];
    }
    if (nextUrlToLoad)
    {
        [self loadImageFromURL:nextUrlToLoad andAnimationType:_animationType immediate:YES isLocalUrl:nextUrlToLoadIsLocal];
        nextUrlToLoad = nil;
        nextUrlToLoadIsLocal = NO;
    }
}

#pragma mark - Utilities

- (CGRect)calculateFrameForImage:(UIImage*)image
{
    return [self calculateFrameForWidth:image.size.width andHeight:image.size.height keepAspectRatio:_keepAspectRatio fitFromOutside:_fitFromOutside cropAnchor:_cropAnchor];
}

- (CGRect)calculateFrameForWidth:(CGFloat)cx andHeight:(CGFloat)cy keepAspectRatio:(BOOL)keepAspectRatio fitFromOutside:(BOOL)fitFromOutside cropAnchor:(DGImageLoaderViewCropAnchor)cropAnchor
{
    CGRect parentBox = self.frame;
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
    return box;
}

- (UIImage*)imageByScalingImage:(UIImage*)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Caching stuff

- (NSString*)getLocalCachePathForUrl:(NSURL*)url
{
    // an alternative to the NSTemporaryDirectory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = paths.count ? paths[0] : [NSHomeDirectory() stringByAppendingString:@"/Library/Caches"];
    
    const char *urlStr = url.absoluteString.UTF8String;
    unsigned char md5result[16];
    CC_MD5(urlStr, strlen(urlStr), md5result); // This is the md5 call
    path = [path stringByAppendingPathComponent:
            [NSString stringWithFormat:
             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             md5result[0], md5result[1], md5result[2], md5result[3],
             md5result[4], md5result[5], md5result[6], md5result[7],
             md5result[8], md5result[9], md5result[10], md5result[11],
             md5result[12], md5result[13], md5result[14], md5result[15]
             ]];
    return path;
}

- (NSString*)getLocalCachePathForUrl:(NSURL*)url withThumbnailSize:(CGSize)thumbnailSize
{
    // an alternative to the NSTemporaryDirectory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = paths.count ? paths[0] : [NSHomeDirectory() stringByAppendingString:@"/Library/Caches"];
    path = [path stringByAppendingFormat:@"/Thumbnail%f,%f", thumbnailSize.width, thumbnailSize.height];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
        NSError* error = nil;
        if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Can't create cache folder, error: %@", error);
            return nil;
        }
    }
    
    const char *urlStr = url.absoluteString.UTF8String;
    unsigned char md5result[16];
    CC_MD5(urlStr, strlen(urlStr), md5result); // This is the md5 call
    path = [path stringByAppendingPathComponent:
            [NSString stringWithFormat:
             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             md5result[0], md5result[1], md5result[2], md5result[3],
             md5result[4], md5result[5], md5result[6], md5result[7],
             md5result[8], md5result[9], md5result[10], md5result[11],
             md5result[12], md5result[13], md5result[14], md5result[15]
             ]];
    return path;
}

- (UIImage*)imageThumbnailOfImage:(UIImage*)image fromCacheOfURL:(NSURL*)url isFromFile:(BOOL*)fromFile
{
    CGSize neededSize = [self calculateFrameForImage:image].size;
    CGFloat scale = UIScreen.mainScreen.scale;
    neededSize.width *= scale;
    neededSize.height *= scale;
    CGSize currentSize = image.size;
    if (fromFile) *fromFile = YES;
    if (neededSize.width != currentSize.width || neededSize.height != currentSize.height)
    {
        neededSize.width = roundf(neededSize.width);
        neededSize.height = roundf(neededSize.height);
        NSString * thumbCachePath = url ? [self getLocalCachePathForUrl:url withThumbnailSize:neededSize] : nil;
        if (thumbCachePath)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:thumbCachePath])
            {
                image = [UIImage imageWithData:[NSData dataWithContentsOfFile:thumbCachePath options:0 error:nil] scale:scale];
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

- (void)setDefaultImage:(UIImage*)defaultImage
{
    _defaultImage = defaultImage;
    if (isDefaultLoaded)
    {
        if (self.oldImageView)
        {
            if (_defaultImage)
            {
                self.oldImageView.image = defaultImage;
                self.oldImageView.frame = [self calculateFrameForImage:self.oldImageView.image];
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
                self.oldImageView.frame = [self calculateFrameForImage:self.oldImageView.image];
                [self addSubview:self.oldImageView];
            }
        }
    }
}

- (UIImage*)currentVisibleImage
{
    return self.oldImageView.image;
}

- (UIImage*)currentVisibleImageNotDefault
{
    UIImage * result = self.oldImageView.image;
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
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		if (statusCode != 200)
		{
			[self connection:connection didFailWithError:nil];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData 
{
    if (self.connectionData==nil) 
	{
		self.connectionData = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [self.connectionData appendData:incrementalData];
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopAndRemoveConnection];
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	if (self.connectionData != nil)
	{
        [self stopAndRemoveConnection];
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
        
        // Make sure we are using the right URL even on other threads
        NSURL * url = _urlRequest.URL;
        
        BOOL async = _asyncLoadImages;
        int asyncIndex = ++asyncOperationCounter;
        void(^loadBlock)() = ^{
            if (asyncIndex != asyncOperationCounter) return; // Check, maybe we were cancelled, and another operation is on the go...
            UIImage * image = [UIImage imageWithData:_connectionData]; // Might be a heavey operation
            if (asyncIndex != asyncOperationCounter) return; // Check again, maybe we were cancelled, and another operation is on the go...
            
            self.nextImage = image;
            if (self.nextImage)
            {
                NSString *cachePath = [self getLocalCachePathForUrl:url];
                [self.connectionData writeToFile:cachePath options:NSDataWritingAtomic error:nil];
                
                if (_resizeImagesToNeededSize)
                {
                    if (asyncIndex != asyncOperationCounter) return; // Check, maybe we were cancelled, and another operation is on the go...
                    image = [self imageThumbnailOfImage:image fromCacheOfURL:url isFromFile:NULL]; // Might be a heavey operation
                    if (asyncIndex != asyncOperationCounter) return; // Check again, maybe we were cancelled, and another operation is on the go...
                    self.nextImage = image;
                }
                
                void(^playBlock)() = ^{
                    if (asyncIndex != asyncOperationCounter) return; // Check again, maybe we were cancelled, and another operation is on the go...
                    [self playWithAnimation:YES immediate:NO];
                };
                if (async)
                {
                    dispatch_async(dispatch_get_main_queue(), playBlock);
                }
                else
                {
                    playBlock();
                }
            }
        };
        if (async)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), loadBlock);
        }
        else
        {
            loadBlock();
        }
	}
    else
    {
        [self connection:connection didFailWithError:nil];
    }
}

#pragma mark - Public methods

- (void)loadImageFromURL:(NSURL*)url andAnimationType:(DGImageLoaderViewAnimationType)animationType
{
    [self loadImageFromURL:url andAnimationType:animationType immediate:NO isLocalUrl:NO];
}

- (void)loadImageFromURL:(NSURL*)url andAnimationType:(DGImageLoaderViewAnimationType)animationType immediate:(BOOL)immediate isLocalUrl:(BOOL)localUrl
{
    _animationType=animationType;
    
    // If we need to delay loading until the view is actually displayed, and it hasn't yet, then:
    if (_delayActualLoadUntilDisplay && !immediate)
    {
        nextUrlToLoad = url;
        nextUrlToLoadIsLocal = localUrl;
        [self setNeedsDisplay];
        return;
    }
    
    NSString *cachePath = localUrl ? nil : (url?[self getLocalCachePathForUrl:url]:nil);
    
    if (!url || localUrl || [[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        BOOL async = _asyncLoadImages;
        int asyncIndex = ++asyncOperationCounter;
        void(^loadBlock)() = ^{
            if (asyncIndex != asyncOperationCounter) return; // Check, maybe we were cancelled, and another operation is on the go...
            UIImage *image = url ? (localUrl ? [UIImage imageWithContentsOfFile:[url path]] : [UIImage imageWithContentsOfFile:cachePath]) : nil;
            if (asyncIndex != asyncOperationCounter) return; // Check again, maybe we were cancelled, and another operation is on the go...
            
            self.nextImage = image;
            if (self.nextImage)
            {
                BOOL loadedThumbFromFile = YES;
                if (_resizeImagesToNeededSize)
                {
                    if (asyncIndex != asyncOperationCounter) return; // Check, maybe we were cancelled, and another operation is on the go...
                    image = [self imageThumbnailOfImage:self.nextImage fromCacheOfURL:url isFromFile:&loadedThumbFromFile];// Might be a heavey operation
                    if (asyncIndex != asyncOperationCounter) return; // Check again, maybe we were cancelled, and another operation is on the go...
                    self.nextImage = image;
                }
                
                BOOL animate = !_doNotAnimateFromCache || !loadedThumbFromFile;
                void(^playBlock)() = ^{
                    if (asyncIndex != asyncOperationCounter) return; // Check again, maybe we were cancelled, and another operation is on the go...
                    [self playWithAnimation:animate immediate:immediate];
                };
                if (async)
                {
                    dispatch_async(dispatch_get_main_queue(), playBlock);
                }
                else
                {
                    playBlock();
                }
            }
        };
        if (async)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), loadBlock);
        }
        else
        {
            loadBlock();
        }
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
        } else {
            self.indicator.hidden = NO;
            [self bringSubviewToFront:self.indicator];
        }
        [self.indicator startAnimating];
        
        if (self.urlConnection!=nil)
        {
            [self stopAndRemoveConnection];
        }
        if (self.connectionData!=nil)
        {
            self.connectionData=nil;
        }
        
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

- (void)loadImage:(UIImage*)image withAnimationType:(DGImageLoaderViewAnimationType)animationType
{
    if (!image)
    {
        [self reset];
    }
    else
    {
        [self stopAndRemoveConnection];
        BOOL async = _asyncLoadImages;
        int asyncIndex = ++asyncOperationCounter;
        void(^loadBlock)() = ^{
            if (asyncIndex != asyncOperationCounter) return; // Check, maybe we were cancelled, and another operation is on the go...
            UIImage *actualImage = image;
            if (_resizeImagesToNeededSize)
            {
                actualImage = [self imageThumbnailOfImage:actualImage fromCacheOfURL:nil isFromFile:NULL];
            }
            if (asyncIndex != asyncOperationCounter) return; // Check again, maybe we were cancelled, and another operation is on the go...
            
            self.nextImage = actualImage;
            
            BOOL animate = !_doNotAnimateFromCache;
            void(^playBlock)() = ^{
                if (asyncIndex != asyncOperationCounter) return; // Check, maybe we were cancelled, and another operation is on the go...
                [self playWithAnimation:animate immediate:NO];
            };
            if (async)
            {
                dispatch_async(dispatch_get_main_queue(), playBlock);
            }
            else
            {
                playBlock();
            }
        };
        if (async)
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
	self.connectionData=nil;
    waitingForDisplay = NO;
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
        self.oldImageView.frame = [self calculateFrameForImage:self.oldImageView.image];
        [self addSubview:self.oldImageView];
    }
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    _hasImageLoaded = NO;
    isDefaultLoaded = YES;
    nextUrlToLoadIsLocal = NO;
    nextUrlToLoad = nil;
    waitingForDisplayWithAnimation = NO;
    waitingForDisplay = NO;
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
        waitingForDisplay = YES;
        waitingForDisplayWithAnimation = withAnimation;
        [self setNeedsDisplay];
        return;
    }
    
    // Clear animation type if the [withAnimation] argument is not set
    DGImageLoaderViewAnimationType animationType = withAnimation?_animationType:DGImageLoaderViewAnimationTypeNone;
    
    // Prepare next image view for animation
    self.nextImageView = [[UIImageView alloc] initWithImage:self.nextImage];
    self.nextImageView.contentMode = UIViewContentModeScaleToFill;
    self.nextImageView.frame = [self calculateFrameForImage:self.nextImageView.image];
    
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

+ (int)maxAsyncConnections
{
    return s_DGImageLoaderView_maxAsyncConnections;
}

+ (void)setMaxAsyncConnections:(int)max
{
    @synchronized(s_DGImageLoaderView_queuedConnectionsArray)
    {
        s_DGImageLoaderView_maxAsyncConnections = max;
    }
    [DGImageLoaderView continueConnectionQueue];
}

+ (int)activeConnections
{
    return s_DGImageLoaderView_currentActiveConnections;
}

+ (int)totalConnections
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
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^(void){
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
            NSURLConnection * connection = [s_DGImageLoaderView_queuedConnectionsArray objectAtIndex:0];
            [s_DGImageLoaderView_queuedConnectionsArray removeObject:connection];
            [s_DGImageLoaderView_activeConnectionsArray addObject:connection];
            [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [connection start];
        }
    }
}

@end
