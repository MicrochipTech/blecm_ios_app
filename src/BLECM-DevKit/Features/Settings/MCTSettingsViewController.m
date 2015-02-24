//
//  MCTSettingsViewController.m
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

#import <sys/proc.h>
#import "MCTSettingsViewController.h"
#import "MCTAttributionView.h"
#import "MCTSettingsFieldCell.h"
#import "MCTSettingsSwitchCell.h"
#import "MCTDeviceManager.h"
#import "MCTSession.h"
#import "MCTBluetoothManager.h"
#import "MCTNoPeripheralsCell.h"
#import "MCTSettingsHeaderView.h"


typedef NS_ENUM(NSUInteger, MCTSettingsTableViewSection) {
    MCTSettingsTableViewSectionServerAddress,
    MCTSettingsTableViewSectionServerTrust,
    MCTSettingsTableViewSectionDevices,
    MCTSettingsTableViewSectionCount,
};

@interface MCTSettingsViewController () <CBCentralManagerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate,
        CBPeripheralDelegate>

@property(nonatomic, strong) MCTSettingsHeaderView *bluetoothHeaderView;

@property(nonatomic, strong) MCTSettingsFieldCell *serverAddressCell;
@property(nonatomic, strong) MCTSettingsSwitchCell *serverTrustCell;
@property(nonatomic, strong) MCTNoPeripheralsCell *noPeripheralsCell;

@property(nonatomic, strong) MCTDeviceManager *deviceManager;
@property(nonatomic, readwrite, getter = isValidServerAddress) BOOL validServerAddress;

@property(nonatomic, strong) MCTBluetoothManager *bluetoothManager;
@property(nonatomic, strong) NSMutableArray *peripherals;
@property(nonatomic, strong) NSMutableArray *peripheralDiscoveryTimes;

@property(nonatomic, strong) NSTimer *timer;

@end

@implementation MCTSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupTableView];
    [self setupStaticCells];
    [self setupDeviceManager];
    [self setupBluetoothManager];
}

- (void)setupBluetoothManager {
    self.bluetoothManager = [MCTBluetoothManager sharedInstance];
    self.peripherals = [NSMutableArray new];
    self.peripheralDiscoveryTimes = [NSMutableArray new];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(clearOldDevices)
                                                userInfo:nil repeats:YES];
}

- (void)setupDeviceManager {
    [self setDeviceManager:[MCTDeviceManager sharedInstance]];
}

- (void)setupTableView {
    MCTAttributionView *backgroundView = [MCTAttributionView mct_instantiateFromNib];
    SEL action = @selector(handleAttributionTapGesture:);
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:action];
    [gesture setDelegate:self];
    [[self tableView] addGestureRecognizer:gesture];
    [[self tableView] setBackgroundView:backgroundView];
    [[self tableView] setTableFooterView:[UIView new]];
    [[self tableView] registerClass:[UITableViewCell class]
             forCellReuseIdentifier:[UITableViewCell mct_reuseIdentifier]];


}

- (void)setupStaticCells {
    MCTSettingsFieldCell *serverCell = [MCTSettingsFieldCell mct_instantiateFromNib];
    [[serverCell textField] setDelegate:self];
    [[serverCell textField] setPlaceholder:@"Server Address"];
    [[serverCell textField] setReturnKeyType:UIReturnKeyDone];
    [self setServerAddressCell:serverCell];

    MCTSettingsSwitchCell *switchCell = [MCTSettingsSwitchCell mct_instantiateFromNib];
    [[switchCell settingsSwitch] addTarget:self
                                    action:@selector(serverTrustSwitchValueChanged:)
                          forControlEvents:UIControlEventValueChanged];
    [[switchCell titleLabel] setText:@"Ignore Errors"];
    [self setServerTrustCell:switchCell];

    MCTNoPeripheralsCell *noPeripheralsCell = [MCTNoPeripheralsCell mct_instantiateFromNib];
    [noPeripheralsCell setSelectionStyle:UITableViewCellSelectionStyleNone];

    [self setNoPeripheralsCell:noPeripheralsCell];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"peripheralcell"];

    self.bluetoothHeaderView = [MCTSettingsHeaderView mct_instantiateFromNib];
    self.bluetoothHeaderView.textLabel.text = [@"Bluetooth Connections" uppercaseString];
    [self.bluetoothHeaderView hideScanning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.deviceManager connectIfReady];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.bluetoothManager.centralManagerDelegate = self;

    if (self.bluetoothManager.currentPeripheral) {
        [self addPeripheralToList:self.bluetoothManager.currentPeripheral];

    }
    [self.bluetoothHeaderView showScanning];
    [self.bluetoothManager scanForPeripherals];

}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"Stopping scan");
    [self.bluetoothManager stopScanning];

    [super viewWillDisappear:animated];
    [[MCTSession sharedSession] saveSession];
}

#pragma mark - Control events

- (IBAction)handleAttributionTapGesture:(UITapGestureRecognizer *)sender {
    if (self.serverAddressCell.textField.isFirstResponder) {
        [[[self serverAddressCell] textField] resignFirstResponder];
    }
    else {
        NSString *platform = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone";

        NSString *URLString = [NSString stringWithFormat:@"http://www.willowtreeapps.com/?utm_source=%@&utm_medium=%@&utm_campaign=attribution",
                                                         @"com.microchip.blecm.ios", platform];
        NSURL *attributionURL = [NSURL URLWithString:URLString];
        [[UIApplication sharedApplication] openURL:attributionURL];
    }
}

- (IBAction)serverTrustSwitchValueChanged:(UISwitch *)settingsSwitch {
    MCTSession *session = [MCTSession sharedSession];
    [session setShouldIgnoreServerTrustErrors:settingsSwitch.isOn];
    [self.deviceManager connectIfReady];
}


#pragma mark - Field validation

- (BOOL)validateServerAddressString:(NSString *)serverAddress {
    NSString *regex = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:serverAddress];
    [self setValidServerAddress:isValid];
    return isValid;
}

#pragma mark - Update text field status

- (void)updateTextFieldStatus:(UITextField *)textField {
    MCTSession *session = [MCTSession sharedSession];
    if ([textField isEqual:self.serverAddressCell.textField]) {
        if ([self validateServerAddressString:textField.text]) {
            NSURLComponents *components = [NSURLComponents componentsWithString:textField.text];
            [session setServerURL:components.URL];
        }
        else {
            [session setServerURL:nil];
            [textField setTextColor:[[MCTAppearance appearance] buttonTextColor]];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    MCTSession *session = [MCTSession sharedSession];
    if ([textField isEqual:self.serverAddressCell.textField]) {
        [session setServerURL:nil];
    }
    [[self deviceManager] cancelDeviceConnection];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.serverAddressCell.textField]) {
        [self validateServerAddressString:newString];
    }
    [textField setTextColor:[[MCTAppearance appearance] primaryTextColor]];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateTextFieldStatus:textField];
    if (self.serverAddressCell.textField.isEditing == NO)
    {
        [self.deviceManager connectIfReady];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [self updateTextFieldStatus:textField];
//    if ([textField isEqual:self.serverAddressCell.textField] &&
//            self.isValidServerAddress) {
//        return YES;
//    }
    //return self.isValidDeviceUUID;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:point];
    if (indexPath == nil) {
        if (point.y >= (CGRectGetHeight(self.tableView.bounds) - 180.0) ||
                self.serverAddressCell.textField.isFirstResponder) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MCTSettingsTableViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((MCTSettingsTableViewSection) section == MCTSettingsTableViewSectionDevices) {
        if (self.peripherals.count > 0) return self.peripherals.count;
        else return 1;

    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch ((MCTSettingsTableViewSection) indexPath.section) {
        case MCTSettingsTableViewSectionServerAddress: {
            MCTSession *session = [MCTSession sharedSession];
            if (session.serverURL) {
                [[self.serverAddressCell textField] setText:session.serverURL.absoluteString];
                [self setValidServerAddress:YES];
            }
            cell = self.serverAddressCell;
            break;
        }
        case MCTSettingsTableViewSectionServerTrust: {
            MCTSession *session = [MCTSession sharedSession];
            [[[self serverTrustCell] settingsSwitch] setOn:session.shouldIgnoreServerTrustErrors];
            cell = self.serverTrustCell;
            break;
        }
        case MCTSettingsTableViewSectionDevices: {
            if (self.peripherals.count == 0) {
                cell = self.noPeripheralsCell;
                break;
            }

            CBPeripheral *peripheral = self.peripherals[(NSUInteger) indexPath.row];

            UITableViewCell *deviceCell = [self.tableView dequeueReusableCellWithIdentifier:@"peripheralcell"];
            deviceCell.textLabel.text = [NSString stringWithFormat:@"%@", peripheral.name
            ];

            deviceCell.accessoryType = UITableViewCellAccessoryNone;
            cell = deviceCell;

            if ([self.bluetoothManager.currentPeripheral.identifier isEqual:peripheral.identifier]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        }
        default: {
            cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell mct_reuseIdentifier]
                                                   forIndexPath:indexPath];
        }
            break;
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    MCTSettingsHeaderView *view = [MCTSettingsHeaderView mct_instantiateFromNib];
    switch (section) {
        case MCTSettingsTableViewSectionServerAddress: {
            view.textLabel.text = [@"Device Information" uppercaseString];
            [view hideScanning];
            break;
        }
        case MCTSettingsTableViewSectionServerTrust: {
            view.textLabel.text = [@"Server Trust" uppercaseString];
            [view hideScanning];
            break;
        }
        case MCTSettingsTableViewSectionDevices: {
            return self.bluetoothHeaderView;
        }

        default:
            break;
    }
    return view;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MCTSettingsTableViewSectionDevices && self.peripherals.count == 0) {
        return 80;
    } else {
        return 40.0;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == MCTSettingsTableViewSectionDevices) {
        MCTSession *session = [MCTSession sharedSession];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[MCTNoPeripheralsCell class]]) return;

        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [session setDeviceUUID:nil];
            [session setDeviceUUIDassigned:nil];
            [self.bluetoothManager disconnectPeripheral];
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            CBPeripheral *peripheral = self.peripherals[indexPath.row];
            [session setDeviceUUIDassigned:peripheral.identifier.UUIDString];
            [self.bluetoothManager connectPeripheral:peripheral];
        }
    }
    [self.tableView reloadData];
}



#pragma mark CB Central Manager Delegates

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    [self addPeripheralToList:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didFailToConnectPeripheral: %@", error);
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self.bluetoothHeaderView showScanning];
            break;
        case CBCentralManagerStatePoweredOff:
            [self.bluetoothManager disconnectPeripheral];
        default:
            [self.bluetoothHeaderView hideScanning];
    }
}


#pragma mark other functions

- (void)addPeripheralToList:(CBPeripheral *)peripheral {

    if (![self.peripherals containsObject:peripheral]) {
        [self.peripherals addObject:peripheral];
        [self.peripheralDiscoveryTimes addObject:[NSDate date]];
        [self.tableView reloadData];
    } else {
        NSUInteger peripheralIndex = [self.peripherals indexOfObject:peripheral];
        self.peripheralDiscoveryTimes[peripheralIndex] = [NSDate date];
    }
}


- (void)clearOldDevices {

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];

    for (NSUInteger i = 0; i < self.peripheralDiscoveryTimes.count; i++) {
        NSDate *foundDate = self.peripheralDiscoveryTimes[i];
        NSDateComponents *difference = [calendar components:NSCalendarUnitSecond fromDate:foundDate toDate:now
                                                    options:0];
        if ([difference second] > 2) {
            CBPeripheral *p = self.peripherals[i];

            if (![p.identifier isEqual:self.bluetoothManager.currentPeripheral.identifier]) {
                [self.peripherals removeObjectAtIndex:i];
                [self.peripheralDiscoveryTimes removeObjectAtIndex:i];
                [self.tableView reloadData];
            }
        }
    }
}


@end
