//
//  MCTConsoleMonitor.h
//  BLECM-DevKit
//
//  Created by Joel Garrett on 7/30/14.
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

typedef NS_ENUM(NSInteger, MCTConsoleMonitorChangeType)
{
    MCTConsoleMonitorChangeInsert = 1,
    MCTConsoleMonitorChangeDelete = 2,
    MCTConsoleMonitorChangeMove = 3,
    MCTConsoleMonitorChangeUpdate = 4
};

@protocol MCTConsoleMonitorDelegate;

@interface MCTConsoleMonitor : NSObject

@property (nonatomic, weak) id <MCTConsoleMonitorDelegate> delegate;

// The monitoring state
@property (nonatomic, readonly, getter = isMonitoring) BOOL monitoring;

// The current file paths observed by the monitor.
@property (nonatomic, strong, readonly) NSArray *filePaths;

/**
 *  Starts monitoring of the request history
 *  directory contents. Changes to the contents
 *  are reported to the monitor's delegate.
 */
- (void)startMonitoring;

/**
 *  Stops monitoring of the request history
 *  directory contents.
 */
- (void)stopMonitoring;

/**
 *  Returns the file path for the provided
 *  index path. This is used as a convenience
 *  accessor in the app's console view controller.
 *  The file path return can be used to instantiate
 *  an instance of a MCTRequestSummary object.
 *
 *  @see MCTRequestSummary summaryWithContentsOfFile:
 *
 *  @param indexPath the index path
 *
 *  @return a fully qualified file path to a request summary data file
 */
- (NSString *)filePathAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol MCTConsoleMonitorDelegate <NSObject>

// Called when changes are observed in the request history directory.
- (void)consoleMonitorDidChangeContent:(MCTConsoleMonitor *)consoleMonitor;

@end