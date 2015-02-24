//
//  MCTDeviceButtonLEDCell.m
//  BLECM-DevKit
//
//  Created by Joel Garrett on 7/15/14.
//  Copyright (c) 2014 Microchip Technology Inc. and its subsidiaries.
//
//  You may use this software and any derivatives exclusively with Microchip products.
//
//  THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER EXPRESS,
//  IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED WARRANTIES
//  OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE, OR
//  ITS INTERACTION WITH MICROCHIP PRODUCTS, COMBINATION WITH ANY OTHER PRODUCTS, OR
//  USE IN ANY APPLICATION.
//
//  IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
//  INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND WHATSOEVER
//  RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS BEEN ADVISED OF
//  THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE FULLEST EXTENT ALLOWED
//  BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN ANY WAY RELATED TO THIS
//  SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY, THAT YOU HAVE PAID DIRECTLY
//  TO MICROCHIP FOR THIS SOFTWARE.
//
//  MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF THESE
//  TERMS.
//

#import "MCTDeviceButtonLEDCell.h"

@implementation MCTDeviceButtonLEDCell

- (void)awakeFromNib
{
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    MCTAppearance *appearance = [MCTAppearance appearance];
    [[self buttonLabel] setFont:appearance.defaultFont];
    [[self ledLabel] setFont:appearance.defaultFont];
    [[self ledSwitch] setOn:NO];
}

- (void)setButtonStatusOn:(BOOL)isOn
{
    NSString *imageName = @"img_circle_empty";
    if (isOn)
    {
        imageName = @"img_circle_red";
    }
    [[self buttonStatusImageView] setImage:[UIImage imageNamed:imageName]];
}

- (void)setDrawerOpenState:(BOOL)openState
{
    if (openState)
    {
        [[self contentView] removeConstraints:self.removableConstraints];
    }
    else
    {
        [[self contentView] addConstraints:self.removableConstraints];
    }
    [self springAnimate:openState];
}

- (void)springAnimate:(BOOL)openState
{
    CGFloat alpha = (openState) ? 0.0 : 1.0;
    [UIView mct_animateWithLinearSpring:^{
        
        [[self buttonLabel] setAlpha:alpha];
        [[self ledLabel] setAlpha:alpha];
        [self layoutIfNeeded];
        
    }];
}

@end
