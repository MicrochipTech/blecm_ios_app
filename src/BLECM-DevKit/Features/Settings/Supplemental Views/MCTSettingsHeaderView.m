//
//  MCTSettingsHeaderView.m
//  BLECM-DevKit
//
//  Created by Michael Lake on 1/14/15.
//  Copyright (c) 2015 Michael Lake. All rights reserved.
//

#import "MCTSettingsHeaderView.h"
#import "MCTAppearance.h"

@interface MCTSettingsHeaderView ()
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *scanActivityIndicator;
@end

@implementation MCTSettingsHeaderView



- (void) hideScanning {
    self.scanLabel.hidden = YES;
    self.scanActivityIndicator.hidden = YES;
}

- (void) showScanning {
    self.scanLabel.hidden = NO;
    self.scanActivityIndicator.hidden = NO;
}


- (void)awakeFromNib {
    MCTAppearance *appearance = [MCTAppearance appearance];
    [[self textLabel] setFont:appearance.headerFont];

    [[self textLabel] setTextColor:appearance.primaryTextColor];
    [self setBackgroundColor:appearance.secondaryBackgroundViewColor];

}

@end
