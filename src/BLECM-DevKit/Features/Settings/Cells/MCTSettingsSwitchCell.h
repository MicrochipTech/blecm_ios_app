//
//  MCTSettingsSwitchCell.h
//  BLECM-DevKit
//
//  Created by Joel Garrett on 8/29/14.
//  Copyright (c) 2014 Microchip Technology Inc. and its subsidiaries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTAppearance.h"

@interface MCTSettingsSwitchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UISwitch *settingsSwitch;

@end
