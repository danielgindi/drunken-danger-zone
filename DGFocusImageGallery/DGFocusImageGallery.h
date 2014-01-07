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
