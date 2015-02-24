//
//  MCTCharacteristic.h
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

typedef NS_ENUM(NSInteger, MCTCharacteristicType)
{
    MCTCharacteristicTypeButton = 1,
    MCTCharacteristicTypeLED,
    MCTCharacteristicTypePotentiometer,
    
    MCTCharacteristicTypeUnknown = 0
};

typedef NS_ENUM(NSInteger, MCTCharacteristicProperties)
{
	MCTCharacteristicPropertyRead			= 0x01,
	MCTCharacteristicPropertyWrite			= 0x02,
};

extern NSString *const MCTCharacteristicIdentifierAttributeKey;
extern NSString *const MCTCharacteristicValueAttributeKey;
extern NSString *const MCTCharacteristicButtonPrefix;
extern NSString *const MCTCharacteristicLEDPrefix;
extern NSString *const MCTCharacteristicPotentiometerPrefix;
extern float const MCTCharacteristicMaximumPotentiometerValue;

@class MCTDevice;

@interface MCTCharacteristic : NSObject

// The characteristic type.
@property (nonatomic, readonly) MCTCharacteristicType characteristicType;

// The characteristic properties.
@property (nonatomic, readonly) MCTCharacteristicProperties properties;

// The characteristic identifier. This should match the data key name returned from status requests.
@property (nonatomic, strong, readonly) NSString *identifier;

// The characteristic numeric value.
@property (nonatomic, strong) NSNumber *value;

// The back reference to the associated device.
@property (nonatomic, weak) MCTDevice *device;

/**
 *  The default initilizer. Note: Characteristics 
 *  are created and maintained by their associated 
 *  device. There is currently no reason to 
 *  instantiate a characteristic direclty.
 *
 *  @param attributes device generated attribute dictionary
 *
 *  @return a new MCTCharacteristic instance
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

/**
 *  Returns a attribute dictionary for use by
 *  the device when preparing it's attribute
 *  dictionary for sending status updates.
 *
 *  @return characteristic attribute dictionary
 */
- (NSDictionary *)attributeDictionary;

/**
 *  Returns a dictionary containing all of
 *  the characteristic values. This is used 
 *  when constructing the object description
 *  for debug logging.
 *
 *  @return device dictionary
 */
- (NSDictionary *)dictionaryValue;

@end
