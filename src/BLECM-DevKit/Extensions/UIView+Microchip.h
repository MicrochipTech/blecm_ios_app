//
//  UIView+Microchip.h
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

#import <UIKit/UIKit.h>

#pragma mark - Nib loading

@interface UIView (Microchip_NibLoading)

+ (UINib *)mct_nib;
+ (instancetype)mct_instantiateFromNib;
+ (instancetype)mct_instantiateWithNibNamed:(NSString *)nibName;

@end

#pragma mark - Reusability

@interface UIView (Microchip_Reusablility)

+ (NSString *)mct_reuseIdentifier;

@end

#pragma mark - Debugging

@interface UIView (Microchip_Debugging)

- (void)mct_applyLayerBorders;
- (void)mct_applyLayerBordersWithColor:(UIColor *)color;
- (void)mct_applyLayerBordersWithColor:(UIColor *)color lineWidth:(CGFloat)lineWidth;

@end

#pragma mark - Animations

@interface UIView (Microchip_Animations)

+ (void)mct_animateWithLinearSpring:(void (^)(void))animations;
+ (void)mct_animateWithLinearSpring:(void (^)(void))animations
                         completion:(void (^)(BOOL finished))completion;

@end
