//
//  MCTDevice.h
//  BLECM-DevKit
//
//  Created by Joel Garrett on 7/18/14.
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

extern NSString *const MCTDeviceTypeAttributeKey;
extern NSString *const MCTDeviceUUIDAttributeKey;
extern NSString *const MCTDeviceCharacteristicsAttributeKey;

typedef NS_ENUM(NSInteger, MCTDeviceType)
{

    MCTDeviceTypeUnknown = 0,
    MCTDeviceTypeWCM = 1,
    MCTDeviceTypeAWS = 2,
    MCTDeviceTypePhone = 3, //changes that come from phone
    MCTDeviceTypeBLECM4020 = 5, //changes originating device
    MCTDeviceTypeBLECM4220 = 6

};

@class MCTCharacteristic;

@interface MCTDevice : NSObject

// The device UUID read from the characteristic
@property (nonatomic, strong, readonly) NSString *UUID;

// The device characteristics.
@property (nonatomic, strong, readonly) NSArray *characteristics;

// The state of unprocessed changes to characteristic values.
@property (nonatomic, readonly) BOOL hasChanges;

/**
 *  Only use this initilizer when creating a
 *  MCTDevice instance. Initilizing with 
 *  [MCTDevice new] will result in an invalid
 *  device instance. Providing a nil or zero
 *  length UUID will raise an assertion.
 *
 *  @param UUID a valid UUID
 *
 *  @return a new MCTDevice
 */
- (instancetype)initWithUUID:(NSString *)UUID;

/**
 *  Updates the device and it's characteristics
 *  with the values provided in the attributes
 *  dictionary. This accepts the raw JSON
 *  attributes returned from a successful
 *  MCTRequest.
 *
 *  @param attributes JSON device attributes dictionary
 */
- (void)updateWithAttributes:(NSDictionary *)attributes;

/**
 *  Returns a JSON device attributes dictionary 
 *  with pending changes applied. This can be
 *  used for sending status updates with a
 *  MCTRequest.
 *
 *  @return JSON device attributes dictionary
 */
- (NSDictionary *)attributeDictionary;

/**
 *  Returns a dictionary containing all of
 *  the device values and characteristics.
 *  This is used when constructing the object
 *  description for debug logging.
 *
 *  @return device dictionary
 */
- (NSDictionary *)dictionaryValue;

/**
 *  Returns an array of device characteristics
 *  that match the provided prefix.
 *
 *  @param prefix a characteristic prefix
 *
 *  @return an array of characteristics or nil if no matches are found
 */
- (NSArray *)characteristicsWithPrefix:(NSString *)prefix;

/**
 *  Writes the value provided for the characteristic
 *  to the devices changes. Nil values are ignored.
 *
 *  @param value          the numeric value
 *  @param characteristic the characteristic
 */
- (void)writeValue:(NSNumber *)value forCharacteristic:(MCTCharacteristic *)characteristic;

/**
 *  Clear any pending changes.
 */
- (void)clearChanges;

@end

