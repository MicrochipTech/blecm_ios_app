//
//  NSData+Microchip.m
//  BLECM-DevKit
//
//  Created by Joel Garrett on 7/29/14.
//  Copyright (c) 2014 Microchip Technology Inc. and its subsidiaries. All rights reserved.
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

#import "NSData+Microchip.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Microchip)

- (NSData *)mct_SHA1
{
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    if (CC_SHA1([self bytes], (CC_LONG)[self length], hash))
    {
        return [NSData dataWithBytes:hash
                              length:CC_SHA1_DIGEST_LENGTH];
    }
    return nil;
}

- (NSString *)mct_SHA1String
{
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
    NSData *SHA1 = [self mct_SHA1];
    if (SHA1.length == CC_SHA1_DIGEST_LENGTH)
    {
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        [SHA1 getBytes:&digest length:CC_SHA1_DIGEST_LENGTH];
        for (int index = 0; index < CC_SHA1_DIGEST_LENGTH; index++)
        {
            [output appendFormat:@"%02x", digest[index]];
        }
        return output;
    }
    return nil;
}

@end
