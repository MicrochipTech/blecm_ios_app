//
//  MCTRequestSummary.h
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

@interface MCTRequestSummary : NSObject <NSCoding>

// The date the request summary was created.
@property (nonatomic, strong) NSDate *createdAt;

// The URL request.
@property (nonatomic, strong) NSURLRequest *request;

// The URL response.
@property (nonatomic, strong) NSURLResponse *response;

// The response error on nil if request was successful.
@property (nonatomic, strong) NSError *responseError;

// The SHA1 hash of the response data or nil if no data was returned.
@property (nonatomic, strong) NSString *responseHash;

// The response string representation or nil if the data could not be converted to a string.
@property (nonatomic, strong) NSString *responseString;

// The request string representation of the request body if it is a POST
@property (nonatomic, strong) NSString *requestString;

#pragma mark - Save/restore

// Saves the summary to the app's console cache.
- (BOOL)saveSummary;

// Deletes the summary from the app's console cache.
- (BOOL)deleteSummary;

// Returns an HTML string of the request summary for use when composing emails.
- (NSString *)HTMLSummary;

// Instantiates a summary with the contents of a summary file.
+ (instancetype)summaryWithContentsOfFile:(NSString *)path;

// Returns the request history directory name.
+ (NSString *)requestHistoryDirectory;

// Returns the file names of all summaries in the history directory.
+ (NSArray *)directoryContents;

// Deletes all summaries in the history directory.
+ (BOOL)clearHistory;

// Returns YES in the directory content is not empty.
+ (BOOL)requestHistoryExist;

@end
