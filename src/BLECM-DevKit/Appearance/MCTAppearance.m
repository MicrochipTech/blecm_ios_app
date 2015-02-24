//
//  MCTAppearance.m
//  BLECM-DevKit
//
//  Created by Joel Garrett on 7/14/14.
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

#import "MCTAppearance.h"

@implementation MCTAppearance

+ (void)applyAppearance
{
    UIColor *redColor = [UIColor colorWithRed:0.91 green:0.18 blue:0.21 alpha:1];
    UIColor *blackColor = [UIColor colorWithRed:0.14 green:0.12 blue:0.13 alpha:1];
    UIColor *lightGreyColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
    UIColor *greyColor = [UIColor colorWithRed:0.81 green:0.81 blue:0.82 alpha:1];
    UIColor *orangeColor = [UIColor colorWithRed:0.91 green:0.68 blue:0.23 alpha:1];
    UIColor *greenColor = [UIColor colorWithRed:0.32 green:0.83 blue:0.4 alpha:1];
    [[self appearance] setPrimaryTintColor:blackColor];
    [[self appearance] setBackgroundViewColor:UIColor.whiteColor];
    [[self appearance] setSecondaryBackgroundViewColor:lightGreyColor];
    [[self appearance] setErrorStatusColor:orangeColor];
    [[self appearance] setSuccessStatusColor:greenColor];
    [[self appearance] setPrimaryTextColor:blackColor];
    [[self appearance] setSecondaryTextColor:greyColor];
    [[self appearance] setButtonTextColor:redColor];
    [[self appearance] setSeparatorViewColor:greyColor];
    
    UIFont *headerFont = [UIFont mct_lightFontOfSize:14.0];
    UIFont *defaultFont = [UIFont mct_regularFontOfSize:17.0];
    UIFont *statusFont = [UIFont mct_regularFontOfSize:14.0];
    UIFont *consoleFont = [UIFont mct_monoSpacedFontOfSize:10.0];
    [[self appearance] setHeaderFont:headerFont];
    [[self appearance] setDefaultFont:defaultFont];
    [[self appearance] setStatusFont:statusFont];
    [[self appearance] setConsoleFont:consoleFont];
    
    [self applyNavigationBarAppearance];
}

+ (void)applyNavigationBarAppearance
{
    UIColor *color = [[self appearance] backgroundViewColor];
    [[UINavigationBar appearance] setBarTintColor:color];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [[self appearance] primaryTextColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
}

@end
