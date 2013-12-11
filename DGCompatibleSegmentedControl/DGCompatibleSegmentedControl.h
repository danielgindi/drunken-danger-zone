//
//  DGCompatibleSegmentedControl.h
//  DGCompatibleSegmentedControl
//
//  Created by Daniel Cohen Gindi on 6/15/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#pragma message("You shouldn't be using DGCompatibleSegmentedControl for your deplyment target! This is intended for \"forward compatibility\" to iOS 7.x when compiling to deployment target < 7.x")
#endif

@interface DGCompatibleSegmentedControl : UISegmentedControl

@end
