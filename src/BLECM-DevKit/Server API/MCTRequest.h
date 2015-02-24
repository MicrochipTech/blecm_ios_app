//
//  MCTRequest.h
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

#import <Foundation/Foundation.h>
#import "MCTRequestSummary.h"

extern NSString *const MCTRequestResponseHashKey;

typedef NS_ENUM(NSInteger, MCTRequestMethod)  {
    MCTRequestMethodGET,
    MCTRequestMethodPOST,
    MCTRequestMethodDELETE,
    MCTRequestMethodPUT
};

typedef NS_ENUM(NSInteger, MCTResponseCode)
{
    MCTResponseCodeNoMessage = 0,
    MCTResponseCodeBadDeviceType = 1,
    MCTResponseCodeBadUUID = 2,
    MCTResponseCodeBadPayload = 3
};

@interface MCTRequest : NSObject

/**
 *  Returns a new MCTRequest object configured
 *  with the provided parameters. You should
 *  never create a new MCTRequest by any other
 *  means. Provided parameters are appended to
 *  the URL string as query parameters for GET
 *  requests. When creating a POST request a
 *  JSON body is constructed from the parameters.
 *  PUT and DELETE request are not currently
 *  supported. Relative URL strings are appended
 *  to the server URL provided by the shared
 *  session.
 *
 *  @see MCTSession sharedSession
 *
 *  @param requestMethod the request method
 *  @param URLString     the relative or absolute URL string
 *  @param parameters    the request parameters
 *
 *  @return a new MCTRequest
 */
+ (instancetype)requestWithMethod:(MCTRequestMethod)requestMethod
                        URLString:(NSString *)URLString
                       parameters:(NSDictionary *)parameters;

@property (readonly, nonatomic) MCTRequestMethod requestMethod;

// The request URL
@property (readonly, nonatomic) NSURL *URL;

// The parameters
@property (readonly, nonatomic) NSDictionary *parameters;

// Set to YES to ignore errors validating server certificates
@property (readwrite, nonatomic) BOOL shouldIgnoreServerTrustErrors;

// Returns a NSURLRequest for use with NSURLConnection/NSURLSessionManager.
- (NSURLRequest *)preparedURLRequest;

// Returns a resumed NSURLSessionDataTask initialized using the preparedURLRequest.
- (NSURLSessionDataTask *)performRequestWithHandler:(void (^)(id responseObject, MCTRequestSummary *requestSummary))handler;

@end
