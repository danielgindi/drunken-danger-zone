//
//  DGFocusImageGallery.h
//  DGFocusImageGallery
//
//  Created by Daniel Cohen Gindi on 11/13/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  This is a UIViewController which shows an image or a set of images
//    in a full-screen with the option to zoom in-out,
//    pan and rotate, close, and page between images.
//  The DGFocusImageGallery will show originating in a region on the screen where
//    a thumbnail of the image (or a cropped version of the image) was visible.
//
//  DGFocusImageGallery downloads the full images from the supplied URLs,
//    and caches them in the Caches folder.
//  The cache file naming is compatible with the DGImageLoaderView,
//    so images downloaded with it will immediately be availble for DGFocusImageGallery.
//

#import <UIKit/UIKit.h>

typedef enum _DGFocusImageGalleryCropAnchor
{
	DGFocusImageGalleryCropAnchorCenterCenter,
	DGFocusImageGalleryCropAnchorCenterLeft,
	DGFocusImageGalleryCropAnchorCenterRight,
	DGFocusImageGalleryCropAnchorTopCenter,
	DGFocusImageGalleryCropAnchorTopLeft,
    DGFocusImageGalleryCropAnchorTopRight,
    DGFocusImageGalleryCropAnchorBottomCenter,
    DGFocusImageGalleryCropAnchorBottomLeft,
    DGFocusImageGalleryCropAnchorBottomRight
} DGFocusImageGalleryCropAnchor;

@interface DGFocusImageGallery : UIViewController

+ (DGFocusImageGallery*)showInView:(UIView*)view withImageFromView:(UIView*)sourceView  andGalleryUrls:(NSArray*)galleryUrls andCurrentImageIndex:(NSInteger)currentImage whenInitImageIsFitFromOutside:(BOOL)fitFromOutside andCropAnchor:(DGFocusImageGalleryCropAnchor)cropAnchor keepingAspectRatio:(BOOL)keepAspectRatio;

+ (DGFocusImageGallery*)activeGallery;

@property (nonatomic, assign) BOOL allowImageRotation;

/*! Maximum asynchronous connections that can be used to load images.
 The default is 8.
 @return The max connections */
- (int)maxAsyncConnections;

/*! Maximum asynchronous connections that can be used to load images
 @param int The max connections */
- (void)setMaxAsyncConnections:(int)max;

/*! Current active connections used by this instance
 @param int The active connections count */
- (int)activeConnections;

/*! Total connections which include active + pending connections, used by this instance
 @param int The total connections count */
- (int)totalConnections;

@end
