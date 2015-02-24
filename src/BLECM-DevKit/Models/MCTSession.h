//
//  MCTSession.h
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

#import <Foundation/Foundation.h>

extern NSString *const MCTSessionArchiveKey;

@interface MCTSession : NSObject <NSCoding>

// The configured server URL from the settings view
@property (nonatomic, strong) NSURL *serverURL;

// The configured device UUID from the settings view
@property (nonatomic, strong) NSString *deviceUUID;

// The configured device serial number read populated by characteristic
@property (nonatomic, strong) NSString *deviceUUIDassigned;

// Hardware model that we had last connected to
@property (nonatomic, strong) NSString *hardwareModel;

// The configured server trust error preference from the settings view
@property (nonatomic, readwrite) BOOL shouldIgnoreServerTrustErrors;

// Shared session object
+ (instancetype)sharedSession;

/**
 *  Validates the configured server URL and
 *  device UUID. Returns YES if validation
 *  passes.
 *
 *  @return session is fully configured
 */
- (BOOL)isFullyConfigured;

#pragma mark - Archiving

// Saves the session
- (BOOL)saveSession;

// Restores the saved session
- (BOOL)restoreSession;

@end
