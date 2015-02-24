//
//  MCTRequestSummary.m
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

#import "MCTRequestSummary.h"

@implementation MCTRequestSummary

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setCreatedAt:[NSDate date]];
    }
    return self;
}

#pragma mark - Save/restore

- (NSString *)filePath
{
    if (self.createdAt)
    {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HHmmssSSS"];
        NSString *fileName = [formatter stringFromDate:self.createdAt];
        NSString *suffix = self.request.HTTPMethod;
        if (self.responseHash.length > 5)
        {
            suffix = [[self responseHash] substringToIndex:4];
        }
        fileName = [fileName stringByAppendingFormat:@"-%@", suffix];
        NSString *path = [[self class] requestHistoryDirectory];
        path = [path stringByAppendingPathComponent:fileName];
        path = [path stringByAppendingPathExtension:@"history"];
        return path;
    }
    return nil;
}

- (BOOL)saveSummary
{
    BOOL success = NO;
    if (self.responseError && self.responseError.code == -999)
    {
        success = NO;
    }
    else
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        if (data)
        {
            success = [data writeToFile:[self filePath] atomically:YES];
        }
    }
    return success;
}

- (BOOL)deleteSummary
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    [manager removeItemAtPath:[self filePath]
                        error:&error];
    return (error == nil);
}

- (NSString *)HTMLSummary
{
    NSString *HTMLSummary = [NSString stringWithFormat:@"<html><body><h4>%@: %@</h4>",
                             self.request.HTTPMethod,
                             self.request.URL.absoluteString];
    if (self.request.HTTPBody)
    {
        HTMLSummary = [HTMLSummary stringByAppendingFormat:@"<strong>Body</strong><hr />"];
        NSData *data = self.request.HTTPBody;
        NSString *bodyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        HTMLSummary = [HTMLSummary stringByAppendingFormat:@"<p><code>%@</code></p>", bodyString];
    }
    
    if (self.responseString.length)
    {
        HTMLSummary = [HTMLSummary stringByAppendingFormat:@"<strong>Response</strong><hr />"];
        HTMLSummary = [HTMLSummary stringByAppendingFormat:@"<p><code>%@</code></p>",
                       self.responseString];
    }
    
    if (self.responseError)
    {
        HTMLSummary = [HTMLSummary stringByAppendingFormat:@"<strong>Error</strong><hr />"];
        HTMLSummary = [HTMLSummary stringByAppendingFormat:@"<p>(%ld) %@</p>",
                       (long)self.responseError.code,
                       self.responseError.localizedDescription];
    }
    
    HTMLSummary = [HTMLSummary stringByAppendingString:@"<br /><br /></body></html>"];
    return HTMLSummary;
}

+ (instancetype)summaryWithContentsOfFile:(NSString *)path
{
    MCTRequestSummary *summary = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path])
    {
        @try {
            summary = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
        @catch (NSException *exception) {
            [manager removeItemAtPath:path error:nil];
        }
    }
    return summary;
}

+ (NSString *)requestHistoryDirectory
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"RequestHistory"];
    [self createDirectoryAtPathIfNeeded:path];
    return path;
}

+ (void)createDirectoryAtPathIfNeeded:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])
    {
        [manager createDirectoryAtPath:path
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    }
}

+ (NSArray *)directoryContents
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *history = [manager contentsOfDirectoryAtPath:[self requestHistoryDirectory]
                                                    error:&error];
    
    if (error == nil)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] %@", @"history"];
        history = [history filteredArrayUsingPredicate:predicate];
        return history;
    }
    return nil;
}

+ (BOOL)clearHistory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [self directoryContents];
    NSError *error = nil;
    for (NSString *fileName in files)
    {
        NSString *path = [[self requestHistoryDirectory] stringByAppendingPathComponent:fileName];
        [manager removeItemAtPath:path error:&error];
        if (error)
        {
            break;
        }
    }
    return (error == nil);
}

+ (BOOL)requestHistoryExist
{
    NSArray *history = [self directoryContents];
    return (history.count > 0);
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.createdAt = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(createdAt))];
        self.request = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(request))];
        self.response = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(response))];
        self.responseError = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(responseError))];
        self.responseHash = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(responseHash))];
        self.responseString = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(responseString))];
        self.requestString = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(requestString))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.createdAt forKey:NSStringFromSelector(@selector(createdAt))];
    [aCoder encodeObject:self.request forKey:NSStringFromSelector(@selector(request))];
    [aCoder encodeObject:self.response forKey:NSStringFromSelector(@selector(response))];
    [aCoder encodeObject:self.responseError forKey:NSStringFromSelector(@selector(responseError))];
    [aCoder encodeObject:self.responseHash forKey:NSStringFromSelector(@selector(responseHash))];
    [aCoder encodeObject:self.responseString forKey:NSStringFromSelector(@selector(responseString))];
    [aCoder encodeObject:self.requestString forKey:NSStringFromSelector(@selector(requestString))];
}

@end
