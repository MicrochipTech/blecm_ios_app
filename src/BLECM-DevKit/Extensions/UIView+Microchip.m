//
//  UIView+Microchip.m
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

#import "UIView+Microchip.h"

@implementation UIView (Microchip_NibLoading)

+ (UINib *)mct_nib;
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (instancetype)mct_instantiateFromNib;
{
    return [self mct_instantiateWithNibNamed:nil];
}

+ (instancetype)mct_instantiateWithNibNamed:(NSString *)nibName;
{
    UIView *result = nil;
    if (!nibName.length)
    {
        nibName = NSStringFromClass([self class]);
    }
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    NSArray *topLevelObjects = [nib instantiateWithOwner:nil options:nil];
    
    for (id anObject in topLevelObjects)
    {
        if ([anObject isKindOfClass:[self class]])
        {
            result = anObject;
            break;
        }
    }
    
    return result;
}

@end

@implementation UIView (Microchip_Reusablility)

+ (NSString *)mct_reuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end

@implementation UIView (Microchip_Debugging)

- (void)mct_applyLayerBorders
{
    [self mct_applyLayerBordersWithColor:UIColor.redColor];
}

- (void)mct_applyLayerBordersWithColor:(UIColor *)color
{
    [self mct_applyLayerBordersWithColor:color lineWidth:1.0f];
}

- (void)mct_applyLayerBordersWithColor:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    [[self layer] setBorderColor:color.CGColor];
    [[self layer] setBorderWidth:lineWidth];
}

@end

@implementation UIView (Microchip_Animations)

+ (void)mct_animateWithLinearSpring:(void (^)(void))animations
{
    [self mct_animateWithLinearSpring:animations
                           completion:nil];
}

+ (void)mct_animateWithLinearSpring:(void (^)(void))animations
                         completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.75f
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:animations
                     completion:completion];
}

@end