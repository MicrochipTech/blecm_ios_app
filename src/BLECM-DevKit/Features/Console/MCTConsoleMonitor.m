//
//  MCTConsoleMonitor.m
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

#import "MCTConsoleMonitor.h"
#import "MCTRequestSummary.h"
#import <sys/stat.h>
#import <sys/time.h>
#import <sys/types.h>
#import <sys/fcntl.h>
#import <sys/event.h>

@import UIKit;

@interface MCTConsoleMonitor ()

@property (nonatomic, readwrite, getter = isMonitoring) BOOL monitoring;
@property (nonatomic, strong, readwrite) NSArray *filePaths;

@end

@implementation MCTConsoleMonitor
{
    CFFileDescriptorRef _fileDescriptor;
    CFRunLoopSourceRef  _runLoopSource;
}

- (void)dealloc
{
    [self stopMonitoring];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self updateContents];
    }
    return self;
}

/**
 *  Sets up a CoreFoundation file descriptor to
 *  to the request history directory. Events are
 *  monitored on this descriptor and reported to
 *  the monitor's delegate.
 */
- (void)setupFileDescriptior
{
    int directoryFileDescriptor;
    int eventQueue;
    int returnValue;
    struct kevent eventToAdd;
    
    CFFileDescriptorContext context = {0, (void *)(__bridge CFTypeRef)self, NULL, NULL, NULL};
    
    NSString *path = [MCTRequestSummary requestHistoryDirectory];
    directoryFileDescriptor = open([path fileSystemRepresentation], O_EVTONLY);
    NSAssert(directoryFileDescriptor >= 0, @"File descriptior open failed.");
    
    eventQueue = kqueue();
    NSAssert(kqueue >= 0, @"Event queue creation failed.");
    
    eventToAdd.ident  = directoryFileDescriptor;
    eventToAdd.filter = EVFILT_VNODE;
    eventToAdd.flags  = EV_ADD | EV_CLEAR;
    eventToAdd.fflags = NOTE_WRITE;
    eventToAdd.data   = 0;
    eventToAdd.udata  = NULL;
    
    returnValue = kevent(eventQueue, &eventToAdd, 1, NULL, 0, NULL);
    NSAssert(returnValue == 0, @"Event add to queue failed.");
    
    self->_fileDescriptor = CFFileDescriptorCreate(NULL,
                                                   eventQueue,
                                                   true,
                                                   KQCallback,
                                                   &context);
    
    _runLoopSource = CFFileDescriptorCreateRunLoopSource(NULL, self->_fileDescriptor, 0);
    NSAssert(_runLoopSource != NULL, @"Run loop source creation failed.");
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       _runLoopSource,
                       kCFRunLoopDefaultMode);
    
    CFRelease(_runLoopSource);
    CFFileDescriptorEnableCallBacks(self->_fileDescriptor,
                                    kCFFileDescriptorReadCallBack);
}

/**
 *  Tears down the current monitored file descriptor.
 */
- (void)teardownFileDescriptor
{
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(),
                          _runLoopSource,
                          kCFRunLoopDefaultMode);
    CFFileDescriptorDisableCallBacks(self->_fileDescriptor,
                                     kCFFileDescriptorReadCallBack);
}

#pragma mark - Monitoring start/stop/restart

- (void)startMonitoring
{
    if (self.isMonitoring == NO)
    {
        [self setMonitoring:YES];
        [self setupFileDescriptior];
    }
}

- (void)stopMonitoring
{
    if (self.isMonitoring == YES)
    {
        [self teardownFileDescriptor];
        [self setMonitoring:NO];
    }
}

- (void)restartMonitoring
{
    [self stopMonitoring];
    [self startMonitoring];
}

#pragma mark - Content management and access

/**
 *  Updates the file paths to reflect the
 *  current state of the request history
 *  directory. Results are sorted in reverse
 *  name order placing the newest entries at
 *  the top.
 */
- (void)updateContents
{
    NSArray *fileNames = [MCTRequestSummary directoryContents];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    fileNames = [fileNames sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSString *directory = [MCTRequestSummary requestHistoryDirectory];
    NSMutableArray *filePaths = [NSMutableArray new];
    for (NSString *fileName in fileNames)
    {
        [filePaths addObject:[directory stringByAppendingPathComponent:fileName]];
    }
    [self setFilePaths:filePaths];
}

- (NSString *)filePathAtIndexPath:(NSIndexPath *)indexPath
{
    return [self filePaths][indexPath.item];
}

#pragma mark - Monitoring

/**
 *  Handles events on the monitored file descriptor.
 *  Invokes updates to the current contents and
 *  notifies the monitor's delegate.
 */
- (void)handleQueueEvent
{
    int eventQueue;
    struct kevent event;
    struct timespec timeout = {0, 0};
    int eventCount;
    
    eventQueue = CFFileDescriptorGetNativeDescriptor(self->_fileDescriptor);
    NSAssert(eventQueue >= 0, @"Event queue request failed.");
    
    eventCount = kevent(eventQueue, NULL, 0, &event, 1, &timeout);
    NSAssert((eventCount >= 0) && (eventCount < 2), @"Event count is out of bounds.");
    
    if (eventCount == 1)
    {
        [self updateContents];
        if (self.delegate)
        {
            [[self delegate] consoleMonitorDidChangeContent:self];
        }
    }
    CFFileDescriptorEnableCallBacks(self->_fileDescriptor,
                                    kCFFileDescriptorReadCallBack);
}

// The file descriptor's call back function.
static void KQCallback(CFFileDescriptorRef fileDescriptor,
                       CFOptionFlags callBackTypes,
                       void *info)
{
    MCTConsoleMonitor *monitor = (MCTConsoleMonitor *)(__bridge id)(CFTypeRef)info;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [monitor handleQueueEvent];
        
    });
}

@end
