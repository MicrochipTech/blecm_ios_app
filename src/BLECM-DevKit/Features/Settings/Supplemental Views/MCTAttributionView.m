//
//  MCTAttributionView.m
//  BLECM-DevKit
//
//  Created by Joel Garrett on 7/15/14.
//  Copyright (c) 2014 Microchip Technology Inc. All rights reserved.
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

#import "MCTAttributionView.h"

@implementation MCTAttributionView

- (void)awakeFromNib {
    MCTAppearance *appearance = [MCTAppearance appearance];
    [self setBackgroundColor:appearance.secondaryBackgroundViewColor];
    [self setupVersionLabel];
}

- (void)setupVersionLabel {
    MCTAppearance *appearance = [MCTAppearance appearance];
    [[self versionLabel] setFont:[UIFont mct_lightFontOfSize:12.0]];
    [[self versionLabel] setTextColor:appearance.primaryTextColor];

    NSString *bundleVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];

    [[self versionLabel] setText:[NSString stringWithFormat:@"v%@", bundleVersion]];
}

@end
