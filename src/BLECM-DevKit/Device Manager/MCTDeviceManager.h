//
//  MCTDeviceManager.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MCTDeviceManagerState)
{
    MCTDeviceManagerStateUnknown = 0,
    MCTDeviceManagerStateReady,
    MCTDeviceManagerStateConnected,
    MCTDeviceManagerStateError
};

@class MCTDevice;
@protocol MCTDeviceManagerDelegate;

@interface MCTDeviceManager : NSObject

@property (nonatomic, weak) id <MCTDeviceManagerDelegate> delegate;

// The device manager state
@property (nonatomic, readonly) MCTDeviceManagerState state;

// The currently connected device
@property (nonatomic, strong) MCTDevice *connectedDevice;

/**
 *  Use this flag to control automatic polling of
 *  device updates. Setting to YES will start the 
 *  polling timer if a connected device exist and 
 *  timer is not currently started.
 */
@property (nonatomic) BOOL shouldPollDeviceForUpdates;

+ (instancetype)sharedInstance;

/**
 *  Pass a new MCTDevice instance with a valid
 *  UUID to have the manager establish a connection.
 *  Automatic update polling will begin on success
 *  if it has been enabled.
 *  @see shouldPollDeviceForUpdates
 *
 *  @param device a device with valid UUID
 */
- (void)connectDevice:(MCTDevice *)device;

- (void)connectIfReady;

/**
 *  Cancels the connection to the current
 *  device and prepares the device manager
 *  for reuse.
 */
- (void)cancelDeviceConnection;

@end

@protocol MCTDeviceManagerDelegate <NSObject>

// Called when the device manager state changes.
- (void)deviceManagerDidUpdateState:(MCTDeviceManager *)manager;

@optional

// Called on successful connection to a device.
- (void)deviceManager:(MCTDeviceManager *)central didConnectDevice:(MCTDevice *)device;

// Called on failed connection to a device or when automatic updates fail.
- (void)deviceManager:(MCTDeviceManager *)central didFailToConnectDevice:(NSError *)error;

// Called when an updateWithAttributes: modifies characteristic values
- (void)deviceDidUpdateCharacteristicValues:(MCTDevice *)device;


@end
