//
// Created by Michael Lake on 1/13/15.
//  Copyright (c) 2015 Microchip Technology Inc. and its subsidiaries.
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

#import "MCTBluetoothManager.h"
#import "Endian.h"
#import "MCTDeviceManager.h"
#import "MCTCharacteristic.h"
#import "MCTSession.h"

static NSString *const blecmServiceUUIDString = @"28238791-EC55-4130-86E0-002CD96AEC9D";

static NSString *const switchCharactersticUUIDString = @"8F7087BD-FDF3-4B87-B10F-ABBF636B1CD5";
static NSString *const ledCharactersticUUIDString = @"CD830609-3AFA-4A9D-A58B-8224CD2DED70";
static NSString *const potCharactersticUUIDString = @"362232E5-C5A9-4AF6-B30C-E208F1A9AE3E";

static NSString *const informationServiceUUIDString = @"180A";

static NSString *const serialCharactersticUUIDString = @"2A25";
static NSString *const modelCharactersticUUIDString = @"2A24";

@interface MCTBluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate>


@end

@implementation MCTBluetoothManager {

}
- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"Initialized Bluetooth Manager");
        self.bluetoothManagerDelegates = [NSMutableArray new];
    }

    return self;
}

- (CBCentralManager *)centralManager {
    if (_centralManager == nil){
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _centralManager;
}


+ (instancetype)sharedInstance; {
    static MCTBluetoothManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [MCTBluetoothManager new];
    });
    return _sharedInstance;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        if (self.scanning) {
            [self scanForPeripherals];
        }
    }
    if (self.centralManagerDelegate) {
        [self.centralManagerDelegate centralManagerDidUpdateState:central];
    }
}


- (void)scanForPeripherals {
    self.scanning = TRUE;

    switch (self.centralManager.state) {

        case CBCentralManagerStatePoweredOn:
            NSLog(@"initiating scan");
            [self.centralManager scanForPeripheralsWithServices:@[
                            [CBUUID UUIDWithString:blecmServiceUUIDString],
                            [CBUUID UUIDWithString:informationServiceUUIDString],
                    ]
                                                        options:@{
                                                                CBCentralManagerScanOptionAllowDuplicatesKey : @YES
                                                        }
            ];
            break;
        default:
            NSLog(@"Central Manager Bluetooth is not powered on, current state: %ld", self.centralManager.state);
            break;
    }
}

- (void)stopScanning {
    self.scanning = FALSE;
    [self.centralManager stopScan];
}

- (void)setCurrentPeripheral:(CBPeripheral *)currentPeripheral {
    _currentPeripheral = currentPeripheral;
    _currentPeripheral.delegate = self;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSString *deviceUUIDassigned = [[MCTSession sharedSession] deviceUUIDassigned];
    if (deviceUUIDassigned != nil && [peripheral.identifier.UUIDString isEqual:deviceUUIDassigned]){
        if (self.currentPeripheral == nil){
            [self stopScanning];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self connectPeripheral:peripheral];
            });
        }

    }

    if (self.centralManagerDelegate) {
        [self.centralManagerDelegate centralManager:central didDiscoverPeripheral:peripheral
                                  advertisementData:advertisementData RSSI:RSSI];
    }
}

- (void)connectPeripheral:(CBPeripheral *)peripheral {

    NSLog(@"Connecting to peripheral");
    [self setCurrentPeripheral:peripheral];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)disconnectPeripheral {
    NSLog(@"disconnectPeripheral");
    if (self.currentPeripheral) {
        NSLog(@"Disconnecting current peripheral");

        if (self.currentPeripheral.services != nil) {
            for (CBService *service in self.currentPeripheral.services) {
                if (service.characteristics != nil) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                            if (characteristic.isNotifying) {
                                NSLog(@"unsubscribing from notifying characteristic: %@", characteristic.UUID
                                        .UUIDString);
                                [self.currentPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            }
                    }
                }
            }
        }

    }
    if ([self currentPeripheral] != nil){
        [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
    }
    self.currentPeripheral = nil;
    [self scanForPeripherals];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    NSLog(@"Connected, discovering services");

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Here your non-main thread.
        sleep(1);

        dispatch_async(dispatch_get_main_queue(), ^{
            //Here you returns to main thread.
            [peripheral discoverServices:@[
                    [CBUUID UUIDWithString:informationServiceUUIDString]
                    ]];
        });
    });


    for (id <MCTBluetoothManagerDelegate> delegate in self.bluetoothManagerDelegates){
        [delegate didUpdateConnectionState:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral");
    if (error) NSLog(@"error disconnecting peripheral: %@", error);
    self.currentPeripheral = nil;

    for (id <MCTBluetoothManagerDelegate> delegate in self.bluetoothManagerDelegates){
        [delegate didUpdateConnectionState:peripheral];
    }
    [self scanForPeripherals];
}

- (void)refreshCharacteristics{
    NSLog(@"MCTBluetoothManager:refreshCharacteristics");
    if (self.currentPeripheral){
        for (CBService *service in self.currentPeripheral.services) {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:blecmServiceUUIDString]]){
                [self.currentPeripheral discoverCharacteristics:@[
                        [CBUUID UUIDWithString:ledCharactersticUUIDString],
                        [CBUUID UUIDWithString:potCharactersticUUIDString],
                        [CBUUID UUIDWithString:switchCharactersticUUIDString]
                ]                        forService:service];
            }
        }
    }
}

#pragma mark CBPeripheral Delegates

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {

    NSLog(@"peripheral didDiscoverServices");
    if (error) NSLog(@"error: %@", error);

    for (CBService *service in peripheral.services){
        //On the first service discovery, we've asked for the deviceInformation service only and it returns only one
        // service. On the next service discovery, we ask only for the custom BLECM service, but iOS has already seen
        // the other service, therefore it is listed too. The service count is used to make sure we only ask for the
        // serial characteristic once.

        if ([service.UUID isEqual:[CBUUID UUIDWithString:informationServiceUUIDString]] && peripheral.services.count == 1){

            [peripheral discoverCharacteristics:@[
                    [CBUUID UUIDWithString:modelCharactersticUUIDString],
                            [CBUUID UUIDWithString:serialCharactersticUUIDString]] //characteristic for serial number
                                     forService:service];
        }
        if ([service.UUID isEqual:[CBUUID UUIDWithString:blecmServiceUUIDString]]){
            [self refreshCharacteristics];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

    NSLog(@"didDiscoverCharacteristicsForService: %@", [service.UUID UUIDString]);

    if ([service.UUID isEqual:[CBUUID UUIDWithString:informationServiceUUIDString]]){
        for (CBCharacteristic *cbCharacteristic in service.characteristics) {
            if ([cbCharacteristic.UUID isEqual:[CBUUID UUIDWithString:serialCharactersticUUIDString]]
                    || [cbCharacteristic.UUID isEqual:[CBUUID UUIDWithString:modelCharactersticUUIDString]]){
                [peripheral readValueForCharacteristic:cbCharacteristic];
            }
        }
    } else if ([service.UUID isEqual:[CBUUID UUIDWithString:blecmServiceUUIDString]]){
        for (CBCharacteristic *cbCharacteristic in service.characteristics) {
            [peripheral readValueForCharacteristic:cbCharacteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic");

    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }

    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    } else {
        NSLog(@"Notification stopped on %@", characteristic);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    if (error) {
        NSLog(@"error: %@", error);
    }


    if ((characteristic.properties & CBCharacteristicPropertyIndicate
            || characteristic.properties & CBCharacteristicPropertyNotify)
            && !characteristic.isNotifying){
        NSLog(@"Setting notify value for characteristic: %@", characteristic.UUID.UUIDString);
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }

    if ([characteristic.UUID.UUIDString isEqualToString:potCharactersticUUIDString])
    {
        if ([characteristic.value length] == 2)
        {
            Byte byteValue[2];
            [characteristic.value getBytes:&byteValue length:2];
            uint16_t primValue = *(const uint16_t *) byteValue;
            primValue = Endian16_Swap(primValue);

            NSString *stringHex = [NSString stringWithFormat:@"%X", primValue];
            NSInteger iVal = [stringHex integerValue];

            for (id <MCTBluetoothManagerDelegate> delegate in self.bluetoothManagerDelegates){
                [delegate didUpdatePotentiometer:iVal];
            }
        }
    }
    else if([characteristic.UUID.UUIDString isEqualToString:switchCharactersticUUIDString])
    {
        if ([characteristic.value length] == 2) {
            Byte byteValue[2];
            [characteristic.value getBytes:&byteValue length:2];
            uint16_t primValue = *(const uint16_t *) byteValue;
            primValue = Endian16_Swap(primValue);

            NSString *stringHex = [NSString stringWithFormat:@"%04x", primValue];

            BOOL buttonValues[4];

            for (NSInteger i = 0; i < 4; i++) {
                buttonValues[i] = [[stringHex substringWithRange:NSMakeRange(i, 1)] boolValue];
            }
            for (id <MCTBluetoothManagerDelegate> delegate in self.bluetoothManagerDelegates){
                [delegate didUpdateButtons:buttonValues];
            }
        }
    } else if([characteristic.UUID.UUIDString isEqualToString:ledCharactersticUUIDString]){
        if ([characteristic.value length] == 4) {
            NSData *value = characteristic.value;
            Byte byteData[4];
            memcpy(byteData, [value bytes], 4);

            BOOL ledValues[4];
            for (NSInteger i = 0; i < 4; i++) {
                ledValues[i] = (uint8_t) byteData[i];
            }

            for (id <MCTBluetoothManagerDelegate> delegate in self.bluetoothManagerDelegates){
                [delegate didUpdateLeds:ledValues];
            }
        }
    } else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:serialCharactersticUUIDString]]){
        NSString *serialNumber = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];

        for (id <MCTBluetoothManagerDelegate> delegate in self.bluetoothManagerDelegates){
            [delegate didReadSerialNumber:serialNumber withAssignedUUID:peripheral.identifier.UUIDString];
        }
        // Getting the serial number should only happen once, afterward we can go get the BLECM service
        // and characteristics
        [peripheral discoverServices:@[
                [CBUUID UUIDWithString:blecmServiceUUIDString]
        ]];
    } else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:modelCharactersticUUIDString]]){
        NSString *modellNumber = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];

        for (id <MCTBluetoothManagerDelegate> delegate in self.bluetoothManagerDelegates){
            [delegate didReadModelNumber:modellNumber];
        }
    }
}

- (void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)
        data {
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                }
            }
        }
    }
}

- (void)writeLedsToBluetooth:(NSArray *)ledCharacteristics {

    Byte ledArray[4] = {0x01,0x01,0x00,0x01};

    for (NSInteger i=1; i<5; i++){
        for (MCTCharacteristic *characteristic in ledCharacteristics){
            NSString *desiredButton = [NSString stringWithFormat:@"%@%li", MCTCharacteristicLEDPrefix, (long)i];
            if ([characteristic.identifier isEqualToString:desiredButton]){

                if ([characteristic.value intValue] == 1){
                    ledArray[i-1] = 0x01;
                } else {
                    ledArray[i-1] = 0x00;
                }
            }
        }
    }

    NSData *data = [NSData dataWithBytes:&ledArray length:4];

    [self writeCharacteristic:self.currentPeripheral
                        sUUID:blecmServiceUUIDString
                        cUUID:ledCharactersticUUIDString
                         data:data];
};
@end
