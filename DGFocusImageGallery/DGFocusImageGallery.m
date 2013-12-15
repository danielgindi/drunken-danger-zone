//
//  DGFocusImageGallery.m
//  DGFocusImageGallery
//
//  Created by Daniel Cohen Gindi on 11/13/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGFocusImageGallery.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_MAX_ASYNC_CONNECTIONS 8

@interface DGFocusImageGallery () <UIScrollViewDelegate, NSURLConnectionDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray * downloadConnectionRequests;
    NSMutableArray * downloadConnections;
    NSMutableArray * downloadConnectionsData;
    NSMutableArray * activeConnections;
    
    NSMutableArray * imageViewContainers;
    NSMutableArray * imageViews;
    NSMutableArray * startedDownload;
    
    NSArray * galleryUrls;
    UIScrollView * scrollView;
    
    NSInteger maxAsyncConnections;
    
    NSInteger currentSelectedImage;
    
    UIView * topControlsView;
    UIButton * closeButton;
    
    BOOL recognizingPinchOnImageContainer;
}
@end

@implementation DGFocusImageGallery

static DGFocusImageGallery * s_DGFocusImageGallery_activeGallery;

- (id)init
{
    self = [super init];
    if (self)
    {
        maxAsyncConnections = DEFAULT_MAX_ASYNC_CONNECTIONS;
        
        downloadConnectionRequests = [NSMutableArray array];
        downloadConnections = [NSMutableArray array];
        downloadConnectionsData = [NSMutableArray array];
        activeConnections = [NSMutableArray array];
        imageViews = [NSMutableArray array];
        imageViewContainers = [NSMutableArray array];
        
        self.allowImageRotation = YES;
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllConnections];
    [self removeObserver:self forKeyPath:@"view.frame"];
}

- (void)loadView
{
    UIView * view = [[UIView alloc] init];
    
    view.frame = [UIScreen mainScreen].applicationFrame;
    view.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    topControlsView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 80.f)];
    topControlsView.backgroundColor = [UIColor clearColor];
    topControlsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    CAGradientLayer * gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.backgroundColor = [UIColor clearColor].CGColor;
    UIColor * firstColor = [UIColor colorWithWhite:2.f alpha:.1f];
    gradientLayer.colors = @[(id)firstColor.CGColor, (id)[firstColor colorWithAlphaComponent:0.f].CGColor];
    gradientLayer.locations = @[@.8f, @1.f];
    gradientLayer.frame = topControlsView.layer.bounds;
    [topControlsView.layer addSublayer:gradientLayer];
    topControlsView.alpha = 0.f;
    [CATransaction commit];
    
    UIImage * buttonImage = [UIImage imageNamed:@"DGFocusImageGallery-Close.png"];
    CGRect rc;
    rc.size = buttonImage.size;
    rc.origin.y = 10.f;
    rc.origin.x = topControlsView.frame.size.width - rc.size.width - 10.f;
    closeButton = [[UIButton alloc] initWithFrame:rc];
    [closeButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonTouchedUpInside:) forControlEvents:UIControlEventTouchDown];
    [topControlsView addSubview:closeButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (DGFocusImageGallery*)showInView:(UIView*)view withImageFromView:(UIView*)sourceView  andGalleryUrls:(NSArray*)galleryUrls andCurrentImageIndex:(NSInteger)currentImage whenInitImageIsFitFromOutside:(BOOL)fitFromOutside andCropAnchor:(DGFocusImageGalleryCropAnchor)cropAnchor keepingAspectRatio:(BOOL)keepAspectRatio
{
    NSMutableArray * urls = [NSMutableArray array];
    for (NSObject * obj in galleryUrls)
    {
        if (![obj isKindOfClass:[NSURL class]])
        {
            [urls addObject:[NSURL URLWithString:(NSString*)obj]];
        }
        else
        {
            [urls addObject:obj];
        }
    }
    
    NSString *cachePath = [DGFocusImageGallery getLocalCachePathForUrl:(NSURL*)urls[currentImage]];
    UIImage * viewImage = [UIImage imageWithContentsOfFile:cachePath];
    BOOL isFullImage = YES;
    
    if (!viewImage)
    {
        isFullImage = NO;
        UIGraphicsBeginImageContextWithOptions(sourceView.bounds.size, NO, [UIScreen mainScreen].scale);
        [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    DGFocusImageGallery * vc = [[DGFocusImageGallery alloc] init];
    vc->galleryUrls = urls;
    vc->currentSelectedImage = currentImage;
    vc->startedDownload = [[NSMutableArray alloc] init];
    
    for (NSObject * obj in galleryUrls)
    {
        [vc->imageViews addObject:[NSNull null]];
        [vc->imageViewContainers addObject:[NSNull null]];
        [vc->startedDownload addObject:[NSNull null]];
    }
    
    vc.view.frame = CGRectMake(0.f, 0.f, view.frame.size.width, view.frame.size.height);
    [view addSubview:vc.view];
    
    vc->scrollView = [[UIScrollView alloc] initWithFrame:vc.view.bounds];
	vc->scrollView.pagingEnabled = YES;
    vc->scrollView.delegate = vc;
    vc->scrollView.showsHorizontalScrollIndicator = NO;
    vc->scrollView.scrollsToTop = NO;
    vc->scrollView.clipsToBounds = YES;
    vc->scrollView.contentSize = CGSizeMake(vc->scrollView.frame.size.width * galleryUrls.count, vc->scrollView.frame.size.height);
    vc->scrollView.backgroundColor = [UIColor clearColor];
    vc->scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    float xOffset = vc.view.frame.size.width * ((float)currentImage);
    vc->scrollView.contentOffset = CGPointMake(xOffset, 0.f);
    
    UITapGestureRecognizer * globalTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(globalTapGestureRecognized:)];
    globalTapGestureRecognizer.numberOfTapsRequired = 1;
    globalTapGestureRecognizer.numberOfTouchesRequired = 1;
    [vc.view addGestureRecognizer:globalTapGestureRecognizer];
    
    UIImageView * imageView = [vc createImageViewForImage:viewImage atIndex:currentImage];
    CGRect rcDest = imageView.frame;
    
    CGRect rcOrg = [sourceView.superview convertRect:sourceView.frame toView:view];
    rcOrg = [DGFocusImageGallery calculateFrameForWidth:viewImage.size.width andHeight:viewImage.size.height inFrame:rcOrg keepAspectRatio:keepAspectRatio fitFromOutside:fitFromOutside cropAnchor:cropAnchor];
    
    imageView.frame = rcOrg;
    imageView.alpha = 0.f;
    
    [vc.view addSubview:vc->scrollView];
    [vc.view bringSubviewToFront:vc->topControlsView];
    
    if (!isFullImage)
    {
        UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = (CGPoint){rcOrg.size.width / 2.f, rcOrg.size.height / 2.f};
        [imageView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [vc startDownloadingImageAtUrl:urls[currentImage]];
    }
    [vc->startedDownload replaceObjectAtIndex:currentImage withObject:@(YES)];
    
    [UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        imageView.frame = rcDest;
        vc.view.backgroundColor = [UIColor blackColor];
        imageView.alpha = 1.f;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [vc addObserver:vc forKeyPath:@"view.frame" options:NSKeyValueObservingOptionOld context:NULL];
    
    s_DGFocusImageGallery_activeGallery = vc;
    
    return vc;
}

- (UIImageView*)createImageViewForImage:(UIImage*)image atIndex:(NSInteger)index
{
    CGSize destSize = [DGFocusImageGallery calculateFrameForWidth:image.size.width andHeight:image.size.height inFrame:self.view.frame keepAspectRatio:YES fitFromOutside:NO cropAnchor:DGFocusImageGalleryCropAnchorCenterCenter].size;
    
    CGRect rcDest = self.view.frame;
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    rcDest.origin.x = (rcDest.size.width - destSize.width) / 2.f;
    rcDest.origin.y = (rcDest.size.height - destSize.height) / 2.f;
    rcDest.size = destSize;
    imageView.frame = rcDest;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIView * imageViewContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + self.view.frame.size.width * ((float)index), 0.f, self.view.frame.size.width, self.view.frame.size.height)];
    imageViewContainer.backgroundColor = [UIColor clearColor];
    imageViewContainer.clipsToBounds = YES;
    
    [imageViewContainer addSubview:imageView];
    [self->scrollView addSubview:imageViewContainer];
    
    [imageViews replaceObjectAtIndex:index withObject:imageView];
    [imageViewContainers replaceObjectAtIndex:index withObject:imageViewContainer];
    
    UIPinchGestureRecognizer * pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchScaleGestureRecognizedOnImageContainer:)];
    pinchRecognizer.delegate = self;
    [imageViewContainer addGestureRecognizer:pinchRecognizer];
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizedOnImageContainer:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.maximumNumberOfTouches = 2;
    UIRotationGestureRecognizer * rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureRecognizedOnImageContainer:)];
    rotationGestureRecognizer.delegate = self;
    UITapGestureRecognizer * doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizedOnImageContainer:)];
    doubleTapGestureRecognizer.delegate = self;
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [imageViewContainer addGestureRecognizer:pinchRecognizer];
    [imageViewContainer addGestureRecognizer:panGestureRecognizer];
    [imageViewContainer addGestureRecognizer:rotationGestureRecognizer];
    [imageViewContainer addGestureRecognizer:doubleTapGestureRecognizer];
    
    return imageView;
}

+ (DGFocusImageGallery*)activeGallery
{
    return s_DGFocusImageGallery_activeGallery;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect rc = self.view.bounds;
    CGFloat w = rc.size.height;
    rc.size.height = rc.size.width;
    rc.size.width = w;
    rc.origin.x = rc.origin.y;
    [self layoutViewWithFrame:rc];
}

- (void)layoutViewWithFrame:(CGRect)frame
{
    topControlsView.frame = CGRectMake(0.f, 0.f, frame.size.width, 80.f);
    ((CALayer*)topControlsView.layer.sublayers[0]).frame = topControlsView.layer.bounds;
    
    CGRect rc = closeButton.frame;
    rc.origin.y = 10.f;
    rc.origin.x = frame.size.width - rc.size.width - 10.f;
    closeButton.frame = rc;
    
    NSInteger currentImage = scrollView.contentOffset.x / scrollView.frame.size.width;
    scrollView.frame = frame;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * galleryUrls.count, scrollView.frame.size.height);
    scrollView.contentOffset = CGPointMake(scrollView.frame.size.width * ((float)currentImage), 0.f);
    
    NSInteger idx = 0;
    for (UIView * view in imageViewContainers)
    {
        if (view == (id)[NSNull null]) continue;
        
        view.frame = CGRectMake(((float)idx++) * scrollView.frame.size.width, 0.f, scrollView.frame.size.width, scrollView.frame.size.height);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"view.frame"])
    {
        CGRect oldFrame = CGRectNull;
        CGRect newFrame = CGRectNull;
        if([change objectForKey:@"old"] != [NSNull null]) {
            oldFrame = [[change objectForKey:@"old"] CGRectValue];
        }
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
        }
        if (CGRectIsNull(oldFrame) || !CGRectEqualToRect(oldFrame, newFrame))
        {
            [self layoutViewWithFrame:newFrame];
        }
    }
}

#pragma mark - Actions

- (void)closeButtonTouchedUpInside:(id)sender
{
    [UIView animateWithDuration:.5f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.view.alpha = 0.f;
        
    } completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
        [self cancelAllConnections];
        if (s_DGFocusImageGallery_activeGallery == self)
        {
            s_DGFocusImageGallery_activeGallery = nil; // Releease
        }
        
    }];
}

- (void)globalTapGestureRecognized:(UITapGestureRecognizer*)recognizer
{
    [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        if (topControlsView.alpha == 0.f)
        {
            [self.view addSubview:topControlsView];
            topControlsView.alpha = 1.f;
        }
        else
        {
            topControlsView.alpha = 0.f;
        }
        
    } completion:^(BOOL finished) {
        
        if (topControlsView.alpha == 0.f)
        {
            [topControlsView removeFromSuperview];
        }
        
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [imageViewContainers containsObject:gestureRecognizer.view] && [imageViewContainers containsObject:otherGestureRecognizer.view];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        if ([imageViewContainers containsObject:gestureRecognizer.view])
        {
            return recognizingPinchOnImageContainer;
        }
    }
    return YES;
}

#pragma mark - Utilities

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer withView:(UIView*)view
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint locationInView = [gestureRecognizer locationInView:view];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:view.superview];
        
        view.layer.anchorPoint = CGPointMake(locationInView.x / view.bounds.size.width, locationInView.y / view.bounds.size.height);
        view.center = locationInSuperview;
    }
}

- (void)panGestureRecognizedOnImageContainer:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIImageView * imageView = nil;
    for (int j=0; j<gestureRecognizer.view.subviews.count; j++)
    {
        imageView = gestureRecognizer.view.subviews[j];
        if ([imageView isKindOfClass:[UIImageView class]]) break;
        imageView = nil;
    }
    
    if (imageView)
    {
        [self adjustAnchorPointForGestureRecognizer:gestureRecognizer withView:imageView];
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            CGPoint translation = [gestureRecognizer translationInView:[imageView superview]];
            
            imageView.center = CGPointMake(imageView.center.x + translation.x, imageView.center.y + translation.y);
            [gestureRecognizer setTranslation:CGPointZero inView:imageView.superview];
        }
    }
}

- (void)rotationGestureRecognizedOnImageContainer:(UIRotationGestureRecognizer *)gestureRecognizer
{
    UIImageView * imageView = nil;
    for (int j=0; j<gestureRecognizer.view.subviews.count; j++)
    {
        imageView = gestureRecognizer.view.subviews[j];
        if ([imageView isKindOfClass:[UIImageView class]]) break;
        imageView = nil;
    }
    
    if (imageView)
    {
        if (!self.allowImageRotation) return;
        
        [self adjustAnchorPointForGestureRecognizer:gestureRecognizer withView:imageView];
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            imageView.transform = CGAffineTransformRotate(imageView.transform, gestureRecognizer.rotation);
            [gestureRecognizer setRotation:0];
        }
    }
}

- (void)pinchScaleGestureRecognizedOnImageContainer:(UIPinchGestureRecognizer *)gestureRecognizer
{
    UIImageView * imageView = nil;
    for (int j=0; j<gestureRecognizer.view.subviews.count; j++)
    {
        imageView = gestureRecognizer.view.subviews[j];
        if ([imageView isKindOfClass:[UIImageView class]]) break;
        imageView = nil;
    }
    
    if (imageView)
    {
        [self adjustAnchorPointForGestureRecognizer:gestureRecognizer withView:imageView];
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            recognizingPinchOnImageContainer = YES;
            
            imageView.transform = CGAffineTransformScale(imageView.transform, gestureRecognizer.scale, gestureRecognizer.scale);
            [gestureRecognizer setScale:1];
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            CGAffineTransform transform = imageView.transform;
            
            if (sqrt(transform.a*transform.a+transform.c*transform.c) < 1.f ||
                sqrt(transform.b*transform.b+transform.d*transform.d) < 1.f)
            {
                [UIView animateWithDuration:0.15f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    
                    imageView.transform = CGAffineTransformIdentity;
                    imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
                    imageView.center = CGPointMake(imageView.superview.bounds.size.width / 2.f, imageView.superview.bounds.size.height / 2.f);
                    
                    
                } completion:^(BOOL finished) {
                    
                }];
            }
            
            recognizingPinchOnImageContainer = NO;
        }
    }
}

- (void)doubleTapGestureRecognizedOnImageContainer:(UITapGestureRecognizer *)gestureRecognizer
{
    UIImageView * imageView = nil;
    for (int j=0; j<gestureRecognizer.view.subviews.count; j++)
    {
        imageView = gestureRecognizer.view.subviews[j];
        if ([imageView isKindOfClass:[UIImageView class]]) break;
        imageView = nil;
    }
    
    if (imageView)
    {
        [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            if (CGAffineTransformEqualToTransform(imageView.transform, CGAffineTransformIdentity))
            {
                imageView.transform = CGAffineTransformMakeScale(2.f, 2.f);
                imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
                imageView.center = CGPointMake(imageView.superview.bounds.size.width / 2.f, imageView.superview.bounds.size.height / 2.f);
            }
            else
            {
                imageView.transform = CGAffineTransformIdentity;
                imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
                imageView.center = CGPointMake(imageView.superview.bounds.size.width / 2.f, imageView.superview.bounds.size.height / 2.f);
            }
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

+ (CGRect)calculateFrameForWidth:(CGFloat)cx andHeight:(CGFloat)cy inFrame:(CGRect)parentBox keepAspectRatio:(BOOL)keepAspectRatio fitFromOutside:(BOOL)fitFromOutside cropAnchor:(DGFocusImageGalleryCropAnchor)cropAnchor
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
                case DGFocusImageGalleryCropAnchorCenterCenter:
                    box.origin.x = (parentBox.size.width - box.size.width) / 2.f;
                    box.origin.y = (parentBox.size.height - box.size.height) / 2.f;
                    break;
                case DGFocusImageGalleryCropAnchorCenterLeft:
                    box.origin.x = 0.f;
                    box.origin.y = (parentBox.size.height - box.size.height) / 2.f;
                    break;
                case DGFocusImageGalleryCropAnchorCenterRight:
                    box.origin.x = parentBox.size.width - box.size.width;
                    box.origin.y = (parentBox.size.height - box.size.height) / 2.f;
                    break;
                case DGFocusImageGalleryCropAnchorTopCenter:
                    box.origin.x = (parentBox.size.width - box.size.width) / 2.f;
                    box.origin.y = 0.f;
                    break;
                case DGFocusImageGalleryCropAnchorTopLeft:
                    box.origin.x = 0.f;
                    box.origin.y = 0.f;
                    break;
                case DGFocusImageGalleryCropAnchorTopRight:
                    box.origin.x = parentBox.size.width - box.size.width;
                    box.origin.y = 0.f;
                    break;
                case DGFocusImageGalleryCropAnchorBottomCenter:
                    box.origin.x = (parentBox.size.width - box.size.width) / 2.f;
                    box.origin.y = parentBox.size.height - box.size.height;
                    break;
                case DGFocusImageGalleryCropAnchorBottomLeft:
                    box.origin.x = 0.f;
                    box.origin.y = parentBox.size.height - box.size.height;
                    break;
                case DGFocusImageGalleryCropAnchorBottomRight:
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

#pragma mark - Caching stuff

+ (NSString*)getLocalCachePathForUrl:(NSURL*)url
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
    @synchronized(downloadConnections)
    {
        NSMutableData * data = downloadConnectionsData[[downloadConnections indexOfObject:connection]];
        [data appendData:incrementalData];
    }
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    @synchronized(downloadConnections)
    {
        NSInteger connectionIndex = [downloadConnections indexOfObject:connection];
        [downloadConnections removeObjectAtIndex:connectionIndex];
        [downloadConnectionRequests removeObjectAtIndex:connectionIndex];
        [downloadConnectionsData removeObjectAtIndex:connectionIndex];
    }
    [self continueConnectionQueue];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSMutableData * imageData = nil;
    NSURL * currentUrl = nil;
    @synchronized(downloadConnections)
    {
        NSInteger connectionIndex = [downloadConnections indexOfObject:connection];
        imageData = downloadConnectionsData[connectionIndex];
        currentUrl = ((NSURLRequest*)downloadConnectionRequests[connectionIndex]).URL;
        [downloadConnections removeObjectAtIndex:connectionIndex];
        [downloadConnectionRequests removeObjectAtIndex:connectionIndex];
        [downloadConnectionsData removeObjectAtIndex:connectionIndex];
    }
    [self continueConnectionQueue];
    
	if (imageData != nil)
	{
        __block __typeof(self) _self = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSInteger imageIndex = [_self->galleryUrls indexOfObject:currentUrl];
            
            NSString *cachePath = [DGFocusImageGallery getLocalCachePathForUrl:currentUrl];
            [imageData writeToFile:cachePath options:NSDataWritingAtomic error:nil];
            
            UIActivityIndicatorView * activityIndicatorView = imageViews[imageIndex];
            UIImage * viewImage = [UIImage imageWithData:imageData];
            
            if (viewImage)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImageView * imageView = [self createImageViewForImage:viewImage atIndex:imageIndex];
                    imageView.alpha = 0.f;
                    
                    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        activityIndicatorView.alpha = 0.f;
                        imageView.alpha = 1.0;
                    } completion:^(BOOL finished) {
                        [activityIndicatorView removeFromSuperview];
                    }];
                    
                });
            }
            
        });
    }
}

#pragma mark - Connection control

- (void)startDownloadingImageAtUrl:(NSURL*)url
{
    @synchronized(downloadConnections)
    {
        NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        NSURLConnection * urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
        
        [downloadConnectionRequests addObject:urlRequest];
        [downloadConnections addObject:urlConnection];
        [downloadConnectionsData addObject:[NSMutableData data]];
    }
    [self continueConnectionQueue];
}

- (int)maxAsyncConnections
{
    return maxAsyncConnections;
}

- (void)setMaxAsyncConnections:(int)max
{
    @synchronized(downloadConnections)
    {
        maxAsyncConnections = max;
    }
    [self continueConnectionQueue];
}

- (int)activeConnections
{
    @synchronized(downloadConnections)
    {
        return activeConnections.count;
    }
}

- (int)totalConnections
{
    @synchronized(downloadConnections)
    {
        return downloadConnections.count;
    }
}

- (void)continueConnectionQueue
{
    @synchronized(downloadConnections)
    {
        if (downloadConnections.count > activeConnections.count && activeConnections.count < maxAsyncConnections)
        {
            NSURLConnection * connection = nil;
            for (NSURLConnection * conn in downloadConnections)
            {
                if ([activeConnections containsObject:conn]) continue;
                connection = conn;
                break;
            }
            if (!connection) return;
            [activeConnections addObject:connection];
            [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [connection start];
        }
    }
}

- (void)cancelAllConnections
{
    @synchronized(downloadConnections)
    {
        for (NSURLConnection * conn in activeConnections)
        {
            [conn cancel];
        }
        downloadConnections = nil;
        downloadConnectionsData = nil;
        downloadConnectionRequests = nil;
        activeConnections = nil;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)theScrollView
{
    CGFloat pageWidth = theScrollView.bounds.size.width;
    float fractionalPage = theScrollView.contentOffset.x / pageWidth;
    NSInteger nearestNumber = lround(fractionalPage);
    if (nearestNumber != currentSelectedImage)
    {
        currentSelectedImage = nearestNumber;
    }
    
    int imageIndex1 = floor(fractionalPage);
    int imageIndex2 = ceil(fractionalPage);
    
    [self startDownloadForImageIndex:imageIndex1];
    [self startDownloadForImageIndex:imageIndex2];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)theScrollView
{
    CGFloat pageWidth = theScrollView.bounds.size.width;
    float fractionalPage = theScrollView.contentOffset.x / pageWidth;
    NSInteger nearestNumber = lround(fractionalPage);
    
    [self startDownloadForImageIndex:nearestNumber];
    [self startDownloadForImageIndex:nearestNumber + 1];
}

- (void)startDownloadForImageIndex:(int)index
{
    if (index < 0 || index >= startedDownload.count || startedDownload[index] != (id)NSNull.null) return;
    
    NSString * cachePath = [DGFocusImageGallery getLocalCachePathForUrl:(NSURL*)galleryUrls[index]];
    UIImage * viewImage = [UIImage imageWithContentsOfFile:cachePath];
    
    [startedDownload replaceObjectAtIndex:index withObject:@(YES)];
    if (viewImage)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createImageViewForImage:viewImage atIndex:index];
        });
    }
    else
    {
        CGRect scrollArea = scrollView.bounds;
        scrollArea.origin.x = ((float)index) * scrollArea.size.width;
        
        UIActivityIndicatorView * view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGRect rc = [DGFocusImageGallery calculateFrameForWidth:view.frame.size.width andHeight:view.frame.size.height inFrame:scrollArea keepAspectRatio:YES fitFromOutside:NO cropAnchor:DGFocusImageGalleryCropAnchorCenterCenter];
        view.frame = rc;
        view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dispatch_async(dispatch_get_main_queue(), ^{
            [scrollView addSubview:view];
            [view startAnimating];
        });
        [imageViews replaceObjectAtIndex:index withObject:view];
        
        [self startDownloadingImageAtUrl:galleryUrls[index]];
    }
}

@end
