//
//  MCTSettingsSwitchCell.m
//  BLECM-DevKit
//
//  Created by Joel Garrett on 8/29/14.
//  Copyright (c) 2014 Microchip Technology Inc. and its subsidiaries. All rights reserved.
//

#import "MCTSettingsSwitchCell.h"

@implementation MCTSettingsSwitchCell

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    [self setSeparatorInset:UIEdgeInsetsZero];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    MCTAppearance *appearance = [MCTAppearance appearance];
    [[self titleLabel] setFont:appearance.defaultFont];
    [[self titleLabel] setTextColor:appearance.primaryTextColor];
}

@end
