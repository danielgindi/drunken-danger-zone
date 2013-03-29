//
//  DGSlideMenuTableCell.m
//  DGSlideMenuViewController
//
//  Created by Daniel Cohen Gindi on 11/23/12.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//

#import "DGSlideMenuTableCell.h"

@interface DGSlideMenuTableCell ()
{
    UIImageView * iconView;
}
@end

@implementation DGSlideMenuTableCell

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize_DGSlideMenuTableCell];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initialize_DGSlideMenuTableCell];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize_DGSlideMenuTableCell];
    }
    return self;
}

- (void)initialize_DGSlideMenuTableCell
{
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slide_menu_item.png"]];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slide_menu_item_selected.png"]];
    self.textLabel.backgroundColor = [UIColor clearColor];
}

- (void)setIcon:(UIImage *)icon
{
    _icon = icon;
    if (!iconView) return;
    if (_icon || _selectedIcon)
    {
        if ((self.selected || self.highlighted) && _selectedIcon)
        {
            iconView.image = _selectedIcon;
        }
        else
        {
            iconView.image = _icon ? _icon : _selectedIcon;
        }
    }
    else
    {
        [iconView removeFromSuperview];
        iconView = nil;
    }
}

- (void)setSelectedIcon:(UIImage *)selectedIcon
{
    _selectedIcon = selectedIcon;
    if (!iconView) return;
    if (_icon || _selectedIcon)
    {
        if ((self.selected || self.highlighted) && _selectedIcon)
        {
            iconView.image = _selectedIcon;
        }
        else
        {
            iconView.image = _icon ? _icon : _selectedIcon;
        }
    }
    else
    {
        [iconView removeFromSuperview];
        iconView = nil;
    }
}

- (void)setTitleColor:(UIColor *)titleColor
{
    self.textLabel.textColor = titleColor;
}

- (UIColor*)titleColor
{
    return self.textLabel.textColor;
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor
{
    self.textLabel.highlightedTextColor = selectedTitleColor;
}

- (UIColor*)selectedTitleColor
{
    return self.textLabel.highlightedTextColor;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    self.textLabel.font = titleFont;
}

- (UIFont*)titleFont
{
    return self.textLabel.font;
}

- (void)setTitle:(NSString *)title
{
    self.textLabel.text = title;
}

- (NSString*)title
{
    return self.textLabel.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:NO];
    
    iconView.image = ((self.selected || self.highlighted) && _selectedIcon) ? _selectedIcon : (_icon ? _icon : _selectedIcon);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:NO];
    
    iconView.image = ((self.selected || self.highlighted) && _selectedIcon) ? _selectedIcon : (_icon ? _icon : _selectedIcon);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentFrame = self.contentView.frame;
    
    if (!iconView && (_icon || _selectedIcon))
    {
        iconView = [[UIImageView alloc] init];
        iconView.backgroundColor = [UIColor clearColor];
        iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:iconView];
        
        if (_icon || _selectedIcon)
        {
            if ((self.selected || self.highlighted) && _selectedIcon)
            {
                iconView.image = _selectedIcon;
            }
            else
            {
                iconView.image = _icon ? _icon : _selectedIcon;
            }
        }
    }
    
    CGRect iconFrame;
    iconFrame.origin.x = 0.f;
    iconFrame.origin.y = 0.f;
    iconFrame.size.width = 46.f;
    iconFrame.size.height = contentFrame.size.height;
    iconView.frame = iconFrame;
    
    CGSize size = [self.textLabel sizeThatFits:CGSizeMake(0.f, 0.f)];
    CGRect labelFrame;
    labelFrame.origin.x = 50.f;
    labelFrame.size = size;
    labelFrame.origin.y = (contentFrame.size.height - labelFrame.size.height) / 2.f;
    self.textLabel.frame = labelFrame;
    self.textLabel.backgroundColor = [UIColor clearColor];
}

@end
