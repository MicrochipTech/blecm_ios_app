//
//  MCTCharacteristic.m
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

#import "MCTCharacteristic.h"

NSString *const MCTCharacteristicIdentifierAttributeKey = @"identifier";
NSString *const MCTCharacteristicValueAttributeKey = @"value";
NSString *const MCTCharacteristicButtonPrefix = @"button";
NSString *const MCTCharacteristicLEDPrefix = @"led";
NSString *const MCTCharacteristicPotentiometerPrefix = @"pot";
NSString *const MCTCharacteristicHexValuePrefix = @"0x";
float const MCTCharacteristicMaximumPotentiometerValue = 1023.0f;

@interface MCTCharacteristic ()

@property (nonatomic, strong, readwrite) NSString *identifier;

@end

@implementation MCTCharacteristic

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self)
    {
        self.identifier = attributes[MCTCharacteristicIdentifierAttributeKey];
        self.value = attributes[MCTCharacteristicValueAttributeKey];
    }
    return self;
}

- (NSDictionary *)attributeDictionary
{
    if (self.identifier)
    {
        NSMutableDictionary *attributes = [NSMutableDictionary new];
        [attributes setValue:self.value forKey:self.identifier];
        return attributes;
    }
    return @{};
}

- (MCTCharacteristicType)characteristicType
{
    if ([[self identifier] hasPrefix:MCTCharacteristicButtonPrefix])
    {
        return MCTCharacteristicTypeButton;
    }
    else if ([[self identifier] hasPrefix:MCTCharacteristicLEDPrefix])
    {
        return MCTCharacteristicTypeLED;
    }
    else if ([[self identifier] hasPrefix:MCTCharacteristicPotentiometerPrefix])
    {
        return MCTCharacteristicTypePotentiometer;
    }
    return MCTCharacteristicTypeUnknown;
}

- (MCTCharacteristicProperties)properties
{
    if ([[self identifier] hasPrefix:MCTCharacteristicLEDPrefix])
    {
        return MCTCharacteristicPropertyWrite;
    }
    return MCTCharacteristicPropertyRead;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setValue:self.identifier forKey:MCTCharacteristicIdentifierAttributeKey];
    [dictionary setValue:self.value forKey:MCTCharacteristicValueAttributeKey];
    [dictionary setValue:@(self.characteristicType)
                  forKey:NSStringFromSelector(@selector(characteristicType))];
    [dictionary setValue:@(self.properties)
                  forKey:NSStringFromSelector(@selector(properties))];
    return dictionary;
}

- (NSString *)description
{
    NSString *deviceDescription = [super description];
    deviceDescription = [deviceDescription stringByAppendingFormat:@"\n%@",
                         self.dictionaryValue];
    return deviceDescription;
}

@end
