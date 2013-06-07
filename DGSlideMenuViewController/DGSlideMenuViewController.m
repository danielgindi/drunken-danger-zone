//
//  DGSlideMenuViewController.m
//  DGSlideMenuViewController
//
//  Created by Daniel Cohen Gindi on 11/23/12.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <QuartzCore/QuartzCore.h>
#import "DGSlideMenuViewController.h"
#import "DGSlideMenuTableCell.h"

#define kKeyIdentifier @"key"
#define kKeyTitle @"title"
#define kKeyMap @"map"
#define kKeyArray @"array"
#define kKeyContent @"content"
#define kKeyIcon @"icon"
#define kKeySelectedIcon @"sicon"
#define kKeyTitleColor @"clr"
#define kKeySelectedTitleColor @"sclr"
#define kKeyTitleFont @"font"
#define kDefaultGroup @"{Default}"

#define SECTION_HEADER_HEIGHT 20.f
#define SECTION_HEADER_PADDING_LEFT 8.f
#define SECTION_HEADER_FONT_SIZE 12.f
#define SECTION_HEADER_TEXT_COLOR [UIColor whiteColor]
#define SECTION_HEADER_COLOR_TOP [UIColor colorWithRed:0.318 green:0.322 blue:0.318 alpha:1.000]
#define SECTION_HEADER_COLOR_BOTTOM [UIColor colorWithWhite:0.498 alpha:1.000]

#define TABLE_BACKGROUND_COLOR [UIColor colorWithRed:0.173 green:0.176 blue:0.173 alpha:1.000]

#define kSlideInInterval 0.3
#define kSlideOutInterval 0.1
#define kVisiblePortion 65
#define kMenuTableSize 255

@interface DGSlideMenuViewController ()

@end

@implementation DGSlideMenuViewController
{
    UIViewController *selectedViewController;
    BOOL isFirstViewWillAppear;
    BOOL isSwitchingToViewController;
    
    UITableView *tableView;
    UIView *shield;
    
    NSMutableDictionary *groupsMap;
    NSMutableArray *groupsArray;
    
    NSIndexPath *selectedCellIp;
    NSString *selectedItem, *selectedGroup;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    if (self)
    {
        selectedViewController = rootViewController;
        groupsMap = [NSMutableDictionary dictionary];
        groupsArray = [NSMutableArray array];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        groupsMap = [NSMutableDictionary dictionary];
        groupsArray = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        groupsMap = [NSMutableDictionary dictionary];
        groupsArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - SlideMenuViewController

- (void)tapGestureRecognized:(UIPanGestureRecognizer *)gesture
{
    [self switchToViewController:selectedViewController];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gesture
{
    UIView *panningView = gesture.view;
    CGPoint translation = [gesture translationInView:panningView];
    UIView *movingView = selectedViewController.view;
    
    if (movingView.frame.origin.x + translation.x<0)
    {
        translation.x=0.0;
    }
	
    movingView.center = CGPointMake([movingView center].x + translation.x, [movingView center].y);
    [gesture setTranslation:CGPointZero inView:[panningView superview]];
    
    if ([gesture state] == UIGestureRecognizerStateEnded)
    {
        CGRect bounds = self.view.bounds;
        CGSize size = bounds.size;
        
        CGFloat velocity = [gesture velocityInView:panningView].x;
        
        BOOL shouldOpen = NO;
        
        if (velocity > 0.f)
        {
            shouldOpen = YES;
        }
        else if (velocity < 0.f)
        {
            shouldOpen = NO;
        }
        else
        {
            shouldOpen = movingView.center.x > size.width;
        }
        
        if (shouldOpen)
        {
            [self slideOut];
        }
        else
        {
            
            [UIView animateWithDuration:kSlideInInterval delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
                
                selectedViewController.view.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
                
            } completion:^(BOOL completed) {
                
                [shield removeFromSuperview];
                
            }];
            
        }
	}
}

- (void)switchToViewController:(UIViewController *)viewController
{
    [self switchToViewController:viewController animated:YES];
}

- (void)switchToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    CGRect bounds = self.view.bounds;
    self.view.userInteractionEnabled = NO;
    isSwitchingToViewController = YES;
    if (selectedViewController)
    {
        void (^switchBlockFirst)() = [^{
            
            if ([selectedViewController respondsToSelector:@selector(willMoveToParentViewController:)])
            {
                [selectedViewController willMoveToParentViewController:nil];
            }
            [selectedViewController.view removeFromSuperview];
            
            if ([selectedViewController respondsToSelector:@selector(removeFromParentViewController)])
            {
                [selectedViewController removeFromParentViewController];
            }
            
            if (animated)
            {
                viewController.view.frame = CGRectMake(bounds.size.width, 0, bounds.size.width, bounds.size.height);
            }
            else
            {
                viewController.view.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
            }
            
            if ([self respondsToSelector:@selector(addChildViewController:)])
            {
                [self addChildViewController:viewController];
            }
            [self setupViewControllerShadow:viewController];
            [self.view addSubview:viewController.view];
            
            void (^switchBlockSecond)() = [^{
                
                selectedViewController = viewController;
                if ([viewController respondsToSelector:@selector(didMoveToParentViewController:)])
                {
                    [viewController didMoveToParentViewController:self];
                }
                [shield removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                isSwitchingToViewController = NO;
                
            } copy];
            
            if (animated)
            {
                [UIView animateWithDuration:kSlideInInterval delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    viewController.view.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
                    
                } completion:^(BOOL completed){
                    
                    switchBlockSecond();
                    
                }];
            }
            else
            {
                switchBlockSecond();
            }

        } copy];
        
        if (animated)
        {
            [UIView animateWithDuration:kSlideOutInterval delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                selectedViewController.view.frame = CGRectMake(bounds.size.width, 0, bounds.size.width, bounds.size.height);
                
            } completion:^(BOOL completed) {
                switchBlockFirst();
            }];
        }
        else
        {
            switchBlockFirst();
        }
        
    }
    else
    {
        viewController.view.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
        if ([self respondsToSelector:@selector(addChildViewController:)])
        {
            [self addChildViewController:viewController];
        }
        [self setupViewControllerShadow:viewController];
        [self.view addSubview:viewController.view];
        selectedViewController = viewController;
        [shield removeFromSuperview];
        if ([viewController respondsToSelector:@selector(didMoveToParentViewController:)])
        {
            [viewController didMoveToParentViewController:self];
        }
        self.view.userInteractionEnabled = YES;
        isSwitchingToViewController = NO;
    }
}

- (void)setupViewControllerShadow:(UIViewController *)viewController
{
    CALayer *layer = viewController.view.layer;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = .8f;
    layer.shadowOffset = CGSizeMake(-15, 0);
    layer.shadowRadius = 10.f;
    layer.masksToBounds = NO;
    layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
}

- (void)slideOut
{
    CGRect bounds = self.view.bounds;
    
    if (![selectedViewController.view.subviews containsObject:shield])
    {
        shield.frame = bounds;
        [selectedViewController.view addSubview:shield];
    }
    [self setupViewControllerShadow:selectedViewController];
    
    [UIView animateWithDuration:kSlideInInterval delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        selectedViewController.view.frame = CGRectMake(kMenuTableSize, 0, bounds.size.width, bounds.size.height);
        
    } completion:nil];
}

- (NSObject *)_createGroupWithTitle:(NSString *)title withIdentifier:(NSString *)identifier
{
    NSMutableDictionary *group = [NSMutableDictionary dictionary];
    
    [group setObject:identifier forKey:kKeyIdentifier];
    if (title) [group setObject:title forKey:kKeyTitle];
    
    if ([groupsMap objectForKey:identifier])
    {
        [groupsArray removeObject:[groupsMap objectForKey:identifier]];
    }
    
    [groupsMap setObject:group forKey:identifier];
    return group;
}

- (NSObject *)_createItemWithTitle:(NSString *)title andViewController:(UIViewController *)viewController andIcon:(UIImage *)icon andSelectedIcon:(UIImage *)selectedIcon andTitleColor:(UIColor *)titleColor andSelectedTitleColor:(UIColor *)selectedTitleColor andTitleFont:(UIFont *)titleFont withIdentifier:(NSString *)identifier
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    
    [item setObject:identifier forKey:kKeyIdentifier];
    if (title) [item setObject:title forKey:kKeyTitle];
    if (viewController) [item setObject:viewController forKey:kKeyContent];
    if (icon) [item setObject:icon forKey:kKeyIcon];
    if (selectedIcon) [item setObject:selectedIcon forKey:kKeySelectedIcon];
    if (titleColor) [item setObject:titleColor forKey:kKeyTitleColor];
    if (selectedTitleColor) [item setObject:selectedTitleColor forKey:kKeySelectedTitleColor];
    if (titleFont) [item setObject:titleFont forKey:kKeyTitleFont];
    
    return item;
}

- (BOOL)hasGroup:(NSString *)identifier
{
    if (!identifier)
    {
        identifier = kDefaultGroup;
    }
    return !!groupsMap[identifier];
}

- (void)removeGroup:(NSString *)identifier
{
    if (!identifier)
    {
        identifier = kDefaultGroup;
    }
    if (groupsMap[identifier])
    {
        if (selectedCellIp)
        {
            int section = [groupsArray indexOfObject:groupsMap[identifier]];
            if (selectedCellIp.section>=section)
            {
                if (selectedCellIp.section == 0)
                {
                    selectedCellIp = nil;
                }
                else
                {
                    selectedCellIp = [NSIndexPath indexPathForRow:selectedCellIp.row inSection:selectedCellIp.section - 1];
                }
            }
        }
        [groupsArray removeObject:groupsMap[identifier]];
        [groupsMap removeObjectForKey:identifier];
    }
    [tableView reloadData];
}

- (void)removeItem:(NSString *)item inGroup:(NSString *)groupIdentifier
{
    if (!groupIdentifier)
    {
        groupIdentifier = kDefaultGroup;
    }
    NSDictionary *group = groupsMap[groupIdentifier];
    if (group)
    {
        NSMutableDictionary *itemsMap = [group objectForKey:kKeyMap];
        NSMutableArray *itemsArray = [group objectForKey:kKeyArray];
        if (itemsMap[item])
        {
            if (selectedCellIp && selectedCellIp.section == [groupsArray indexOfObject:group])
            {
                int row = [itemsArray indexOfObject:itemsMap[item]];
                if (selectedCellIp.row>=row)
                {
                    if (selectedCellIp.row == 0)
                    {
                        selectedCellIp = nil;
                    }
                    else
                    {
                        selectedCellIp = [NSIndexPath indexPathForRow:selectedCellIp.row - 1 inSection:selectedCellIp.section];
                    }
                }
            }
            [itemsArray removeObject:itemsMap[item]];
            [itemsMap removeObjectForKey:item];
        }
    }
    [tableView reloadData];
}

- (void)addGroupWithTitle:(NSString *)title withIdentifier:(NSString *)identifier
{
    [self addGroupWithTitle:title withIdentifier:identifier atIndex:-1];
}

- (void)addGroupWithTitle:(NSString *)title withIdentifier:(NSString *)identifier atIndex:(NSInteger)index
{
    NSObject *group = [self _createGroupWithTitle:title withIdentifier:identifier];
    if (index < 0)
    {
        [groupsArray addObject:group];
    }
    else
    {
        [groupsArray insertObject:group atIndex:index];
        if (selectedCellIp && selectedCellIp.section >= index)
        {
            selectedCellIp = [NSIndexPath indexPathForRow:selectedCellIp.row inSection:selectedCellIp.section + 1];
        }
    }
    [tableView reloadData];
}

- (void)addItemWithTitle:(NSString *)title andViewController:(UIViewController *)viewController withIdentifier:(NSString *)identifier andIcon:(UIImage *)icon andSelectedIcon:(UIImage *)selectedIcon andTitleColor:(UIColor *)titleColor andSelectedTitleColor:(UIColor *)selectedTitleColor andTitleFont:(UIFont *)titleFont inGroup:(NSString *)groupIdentifier
{
    [self addItemWithTitle:title andViewController:viewController withIdentifier:identifier andIcon:icon andSelectedIcon:selectedIcon andTitleColor:titleColor andSelectedTitleColor:selectedTitleColor andTitleFont:titleFont inGroup:groupIdentifier atIndex:-1];
}

- (void)addItemWithTitle:(NSString *)title andViewController:(UIViewController *)viewController withIdentifier:(NSString *)identifier andIcon:(UIImage *)icon andSelectedIcon:(UIImage *)selectedIcon andTitleColor:(UIColor *)titleColor andSelectedTitleColor:(UIColor *)selectedTitleColor andTitleFont:(UIFont *)titleFont inGroup:(NSString *)groupIdentifier atIndex:(NSInteger)index
{
    if (!groupIdentifier) groupIdentifier = kDefaultGroup;
    NSMutableDictionary *group = [groupsMap objectForKey:groupIdentifier];
    if (group)
    {
        NSMutableDictionary *itemsMap = [group objectForKey:kKeyMap];
        NSMutableArray *itemsArray = [group objectForKey:kKeyArray];
        if (!itemsMap)
        {
            [group setObject:itemsMap = [NSMutableDictionary dictionary] forKey:kKeyMap];
        }
        if (!itemsArray)
        {
            [group setObject:itemsArray = [NSMutableArray array] forKey:kKeyArray];
        }
        if ([itemsMap objectForKey:identifier])
        {
            [itemsArray removeObject:[itemsMap objectForKey:identifier]];
        }
        NSObject *item = [self _createItemWithTitle:title andViewController:viewController andIcon:icon andSelectedIcon:selectedIcon andTitleColor:titleColor andSelectedTitleColor:selectedTitleColor andTitleFont:titleFont withIdentifier:identifier];
        [itemsMap setObject:item forKey:identifier];
        if (index < 0)
        {
            [itemsArray addObject:item];
        }
        else
        {
            [itemsArray insertObject:item atIndex:index];
            if (selectedCellIp && selectedCellIp.section == [groupsArray indexOfObject:group] && selectedCellIp.row >= index)
            {
                selectedCellIp = [NSIndexPath indexPathForRow:selectedCellIp.row + 1 inSection:selectedCellIp.section];
            }
        }
        [tableView reloadData];
    }
}

- (NSMutableDictionary *)getItem:(NSString *)identifier inGroup:(NSString *)groupIdentifier
{
    if (!groupIdentifier) groupIdentifier = kDefaultGroup;
    NSMutableDictionary *group = [groupsMap objectForKey:groupIdentifier];
    if (group)
    {
        NSMutableDictionary *itemsMap = [group objectForKey:kKeyMap];
        return itemsMap[identifier];
    }
    return nil;
}

- (void)setTitle:(NSString *)title forItem:(NSString *)identifier inGroup:(NSString *)groupIdentifier
{
    NSMutableDictionary *item = [self getItem:identifier inGroup:groupIdentifier];
    if (!item) return;
    
    item[kKeyTitle] = title;
    [self reloadRowForItem:identifier inGroup:groupIdentifier];
}

- (void)setViewController:(UIViewController *)viewController forItem:(NSString *)identifier inGroup:(NSString *)groupIdentifier
{
    NSMutableDictionary *item = [self getItem:identifier inGroup:groupIdentifier];
    if (!item) return;
    
    item[kKeyContent] = viewController;
    [self reloadRowForItem:identifier inGroup:groupIdentifier];
}

- (void)reloadRowForItem:(NSString *)identifier inGroup:(NSString *)groupIdentifier
{
    if (!groupIdentifier) groupIdentifier = kDefaultGroup;
    NSMutableDictionary *group = [groupsMap objectForKey:groupIdentifier];
    if (group)
    {
        int groupIdx = [groupsArray indexOfObject:group];
        int itemIdx = [[group objectForKey:kKeyArray] indexOfObject:[group objectForKey:kKeyMap][identifier]];
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:itemIdx inSection:groupIdx]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - UIViewController

- (void)loadView
{
    CGRect viewFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    view.autoresizesSubviews = YES;
    
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isFirstViewWillAppear)
    {
        [self switchToViewController:selectedViewController animated:NO];
        isFirstViewWillAppear = NO;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView reloadData];
        
        if (_retainSelection && selectedCellIp)
        {
            [tableView selectRowAtIndexPath:selectedCellIp animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    isFirstViewWillAppear = YES;
    
    tableView = [[UITableView alloc] init];
    tableView.backgroundColor = TABLE_BACKGROUND_COLOR;
    tableView.rowHeight = SlideMenuTableCellHeight;
    tableView.sectionHeaderHeight = SECTION_HEADER_HEIGHT;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    tableView.scrollsToTop = NO;
    [self.view addSubview:tableView];
    
    
    shield = [[UIView alloc] initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [shield addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [shield addGestureRecognizer:panGesture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    tableView = nil;
}
         
#pragma mark - UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (aTableView != tableView) return;
    if (isSwitchingToViewController) return;
    
    NSDictionary *group = [groupsArray objectAtIndex:indexPath.section];
    NSDictionary *item = [[group objectForKey:kKeyArray] objectAtIndex:indexPath.row];
    
    BOOL defaultAction = [self _highlightItem:item inGroup:group moveToViewController:YES animated:YES];

    if (!defaultAction)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (_retainSelection && selectedCellIp)
        {
            [tableView selectRowAtIndexPath:selectedCellIp animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else
    {
        selectedCellIp = indexPath;
        if (!_retainSelection)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	if (aTableView != tableView) return 0;
    return groupsArray.count;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	if (aTableView != tableView) return 0;
    return [[[groupsArray objectAtIndex:section] objectForKey:kKeyArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (aTableView != tableView) return nil;
    static NSString *CellIdentifier = @"Cell";
    DGSlideMenuTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[DGSlideMenuTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *group = [groupsArray objectAtIndex:indexPath.section];
    NSDictionary *item = [[group objectForKey:kKeyArray] objectAtIndex:indexPath.row];
    
    cell.icon = [item objectForKey:kKeyIcon];
    cell.selectedIcon = [item objectForKey:kKeySelectedIcon];
    cell.titleColor = [item objectForKey:kKeyTitleColor];
    cell.selectedTitleColor = [item objectForKey:kKeySelectedTitleColor];
    cell.titleFont = [item objectForKey:kKeyTitleFont];
    cell.title = [item objectForKey:kKeyTitle];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
	if (aTableView != tableView) return 0.f;
    NSDictionary *group = [groupsArray objectAtIndex:section];
    NSString *title = [group objectForKey:kKeyTitle];
    if (!title.length) return 0;
    return SECTION_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
	if (aTableView != tableView) return nil;
    NSDictionary *group = [groupsArray objectAtIndex:section];
    NSString *title = [group objectForKey:kKeyTitle];
    if (!title.length) return nil;
    return [self customSectionHeaderViewWithTitle:title];
}

- (UIView *)customSectionHeaderViewWithTitle:(NSString *)title
{
    CGFloat width = tableView.frame.size.width;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, width, SECTION_HEADER_HEIGHT)];
    
    CGRect labelFrame = CGRectMake(SECTION_HEADER_PADDING_LEFT, 0.f, width - SECTION_HEADER_PADDING_LEFT, SECTION_HEADER_HEIGHT);
    
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:SECTION_HEADER_FONT_SIZE];
    label.textColor = SECTION_HEADER_TEXT_COLOR;
    label.text = title;
    
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.colors = @[(id)SECTION_HEADER_COLOR_TOP.CGColor, (id)SECTION_HEADER_COLOR_BOTTOM.CGColor];
    gradient.frame = header.bounds;
    [header.layer addSublayer:gradient];
    
    [header addSubview:label];
    
    return header;
}

- (void)highlightItem:(NSString *)item inGroup:(NSString *)group
{
    [self highlightItem:item inGroup:group moveToViewController:YES animated:YES];
}

- (void)highlightItem:(NSString *)item inGroup:(NSString *)group moveToViewController:(BOOL)moveToViewController animated:(BOOL)animated
{
    if (!group.length) group = kDefaultGroup;
    
    NSDictionary *actualGroup = groupsMap[group];
    NSDictionary *actualItem = ((NSDictionary *)actualGroup[kKeyMap])[item];
    
    if (!actualGroup || !actualItem) return;
    
    [self _highlightItem:actualItem inGroup:actualGroup moveToViewController:moveToViewController animated:animated];
}

- (BOOL)_highlightItem:(NSDictionary *)item inGroup:(NSDictionary *)group moveToViewController:(BOOL)moveToViewController animated:(BOOL)animated
{
    if (!group || !item) return NO;
    
    BOOL defaultAction = moveToViewController;
    if (defaultAction && _delegate && [_delegate respondsToSelector:@selector(slideMenuViewController:selectedMenuAt:fromGroup:)])
    {
        defaultAction = [_delegate slideMenuViewController:self selectedMenuAt:[item objectForKey:kKeyIdentifier] fromGroup:[group objectForKey:kKeyIdentifier]];
    }
    if (defaultAction && !isSwitchingToViewController)
    {
        UIViewController *vc = [item objectForKey:kKeyContent];
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            [((UINavigationController *)vc) popToRootViewControllerAnimated:selectedViewController ? YES : NO];
        }
        if (vc) [self switchToViewController:vc animated:animated];
        else [self switchToViewController:selectedViewController animated:animated];
    }
    
    if (defaultAction)
    {
        selectedCellIp = [NSIndexPath indexPathForRow:[[group objectForKey:kKeyArray] indexOfObject:item] inSection:[groupsArray indexOfObject:group]];
        [tableView selectRowAtIndexPath:selectedCellIp animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return defaultAction;
}

- (NSString *)highlightedGroup
{
    if (selectedCellIp)
    {
        return groupsArray[selectedCellIp.section][kKeyIdentifier];
    }
    return nil;
}

- (NSString *)highlightedItem
{
    if (selectedCellIp)
    {
        return groupsArray[selectedCellIp.section][kKeyArray][selectedCellIp.row][kKeyIdentifier];
    }
    return nil;
}

- (UIViewController *)selectedViewController
{
    return selectedViewController;
}

@end
