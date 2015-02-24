//
//  MCTSettingsHeaderView.h
//  BLECM-DevKit
//
//  Created by Michael Lake on 1/14/15.
//  Copyright (c) 2015 Michael Lake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCTSettingsHeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@property (nonatomic, weak) IBOutlet UILabel *scanLabel;

- (void)hideScanning;

- (void)showScanning;
@end
