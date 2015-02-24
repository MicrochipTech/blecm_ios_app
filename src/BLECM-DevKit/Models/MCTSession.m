//
//  MCTSession.m
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

#import "MCTSession.h"

NSString *const MCTSessionArchiveKey = @"MCTSessionArchiveKey";

@implementation MCTSession

- (id)init
{
    self = [super init];
    if (self)
    {
        // Init
    }
    return self;
}

+ (instancetype)sharedSession;
{
    static MCTSession *_sharedSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSession = [MCTSession new];

        [_sharedSession restoreSession];
    });
    return _sharedSession;
}

- (BOOL)isFullyConfigured
{
    return (self.serverURL != nil && self.deviceUUID != nil);
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.serverURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(serverURL))];
        self.deviceUUID = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(deviceUUID))];
        self.deviceUUIDassigned = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(deviceUUIDassigned))];
        self.shouldIgnoreServerTrustErrors = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(shouldIgnoreServerTrustErrors))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.serverURL forKey:NSStringFromSelector(@selector(serverURL))];
    [aCoder encodeObject:self.deviceUUID forKey:NSStringFromSelector(@selector(deviceUUID))];
    [aCoder encodeObject:self.deviceUUIDassigned forKey:NSStringFromSelector(@selector(deviceUUIDassigned))];
    [aCoder encodeBool:self.shouldIgnoreServerTrustErrors
                forKey:NSStringFromSelector(@selector(shouldIgnoreServerTrustErrors))];
}

#pragma mark - Archiving

- (BOOL)saveSession
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if (data)
    {
        [[NSUserDefaults standardUserDefaults] setObject:data
                                                  forKey:MCTSessionArchiveKey];
        return YES;
    }
    return NO;
}

- (BOOL)restoreSession
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:MCTSessionArchiveKey];
    if (data)
    {
        MCTSession *session = nil;
        @try {
            session = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            [defaults removeObjectForKey:MCTSessionArchiveKey];
        }
        if (session)
        {
            [self setServerURL:session.serverURL];
            [self setDeviceUUID:session.deviceUUID];
            [self setDeviceUUIDassigned:session.deviceUUIDassigned];
            [self setShouldIgnoreServerTrustErrors:session.shouldIgnoreServerTrustErrors];
            return YES;
        }
    }
    return NO;
}

@end
