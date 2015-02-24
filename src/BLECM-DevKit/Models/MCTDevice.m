//
//  MCTDevice.m
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

#import <sys/proc.h>
#import "MCTDevice.h"
#import "MCTCharacteristic.h"
#import "MCTSession.h"

NSString *const MCTDeviceTypeAttributeKey = @"device-type";
NSString *const MCTDeviceUUIDAttributeKey = @"uuid";
NSString *const MCTDeviceCharacteristicsAttributeKey = @"data";

@interface MCTDevice ()

@property (nonatomic, strong, readwrite) NSString *UUID;
@property (nonatomic, strong, readwrite) NSNumber *deviceType;
@property (nonatomic, strong, readwrite) NSMutableArray *characteristics;
@property (nonatomic, strong) NSMutableDictionary *changes;

@end

@implementation MCTDevice

- (instancetype)initWithUUID:(NSString *)UUID
{

    if (!UUID){
        UUID = @"NOT_CONFIGURED";
    }
    NSParameterAssert(UUID);
    NSParameterAssert(UUID.length);
    self = [super init];
    if (self)
    {
        [self setChanges:[NSMutableDictionary new]];
        [self setUUID:UUID];

        NSDictionary *dict = @{
                @"button1": @NO,
                @"button2": @NO,
                @"button3": @NO,
                @"button4": @NO,
                @"led1": @NO,
                @"led2": @NO,
                @"led3": @NO,
                @"led4": @NO,
                @"potentiometer": @0
        };

        [self updateWithCharacteristicData:dict];
    }
    return self;
}

- (void)updateWithAttributes:(NSDictionary *)attributes
{
    // Extract device attributes if needed
    if (attributes[@"mchp"])
    {
        attributes = attributes[@"mchp"][@"device"];
    }
    NSDictionary *characteristData = attributes[MCTDeviceCharacteristicsAttributeKey];
    [self updateWithCharacteristicData:characteristData];
}

- (void)updateWithCharacteristicData:(NSDictionary *)characteristData
{
    NSArray *buttonArray = [self characteristicsWithPrefix:MCTCharacteristicButtonPrefix];

    NSMutableArray *characterists = [NSMutableArray arrayWithCapacity:characteristData.allKeys.count];
    [characteristData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *attributes = @{MCTCharacteristicIdentifierAttributeKey: key,
                                     MCTCharacteristicValueAttributeKey: obj};
        MCTCharacteristic *character = [[MCTCharacteristic alloc] initWithAttributes:attributes];

        if (buttonArray != nil &&
                //ignore button states coming from the server
                ([character.identifier containsString:MCTCharacteristicButtonPrefix]
                )){
        } else {
            [character setDevice:self];
            [characterists addObject:character];
        }
    }];

    [characterists addObjectsFromArray:buttonArray];
    [self setCharacteristics:characterists];
}

- (NSDictionary *)attributeDictionary
{

    NSString *hardwareModel = [[MCTSession sharedSession] hardwareModel];
    enum MCTDeviceType deviceType;
    if ([hardwareModel isEqualToString:@"RN4020"]){
        deviceType = MCTDeviceTypeBLECM4020;
    }else if ([hardwareModel isEqualToString:@"RN4220"]){
        deviceType = MCTDeviceTypeBLECM4220;
    } else {
        deviceType = MCTDeviceTypeUnknown;
        NSLog(@"Uknown device: %@", hardwareModel);
    }

    NSMutableDictionary *charactersticsDict = [NSMutableDictionary new];
    for (MCTCharacteristic *character in self.characteristics)
    {
        [charactersticsDict setValuesForKeysWithDictionary:character.attributeDictionary];
    }
    if (self.changes)
    {
        for (NSString *keyName in self.changes.allKeys){
            if ([keyName containsString:MCTCharacteristicLEDPrefix]){
                deviceType = MCTDeviceTypePhone;
                break;
            }
        }
        NSLog(@"Number of changes overriding: %lu", (unsigned long)self.changes.allKeys.count);
        [charactersticsDict setValuesForKeysWithDictionary:self.changes];
    }
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes setValue:@(deviceType) forKey:MCTDeviceTypeAttributeKey];
    [attributes setValue:self.UUID forKey:MCTDeviceUUIDAttributeKey];
    [attributes setValue:charactersticsDict forKey:MCTDeviceCharacteristicsAttributeKey];
    return @{@"mchp": @{@"device": attributes}};
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setValue:self.deviceType forKey:NSStringFromSelector(@selector(deviceType))];
    [dictionary setValue:self.UUID forKey:NSStringFromSelector(@selector(UUID))];
    NSMutableArray *characterDictionaries = [NSMutableArray new];
    for (MCTCharacteristic *character in self.characteristics)
    {
        NSDictionary *characterDictionary = character.dictionaryValue;
        if (characterDictionary.allKeys.count)
        {
            [characterDictionaries addObject:characterDictionary];
        }
    }
    if (characterDictionaries.count)
    {
        [dictionary setValue:characterDictionaries
                      forKey:NSStringFromSelector(@selector(characteristics))];
    }
    return dictionary;
}

- (NSArray *)characteristicsWithPrefix:(NSString *)prefix
{
    NSArray *filterCharacteristics = nil;
    if (self.characteristics.count)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier BEGINSWITH[c] %@", prefix];
        filterCharacteristics = [[self characteristics] filteredArrayUsingPredicate:predicate];
    }
    return filterCharacteristics;
}

- (BOOL)hasChanges
{
    return self.changes.allValues.count;
}

- (void)writeValue:(NSNumber *)value forCharacteristic:(MCTCharacteristic *)characteristic
{
    NSParameterAssert(characteristic);
    [[self changes] setValue:value forKey:characteristic.identifier];
    characteristic.value = value;
}


- (void)clearChanges
{
    [[self changes] removeAllObjects];
}

- (NSString *)description
{
    NSString *deviceDescription = [super description];
    deviceDescription = [deviceDescription stringByAppendingFormat:@"\n%@",
                         self.dictionaryValue];
    return deviceDescription;
}

@end
