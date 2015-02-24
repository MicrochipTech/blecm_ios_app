//
//  MCTRequest.m
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

#import "MCTRequest.h"
#import "MCTRequestSummary.h"
#import "MCTSession.h"
#import "NSData+Microchip.h"

@import UIKit;

NSString *const MCTRequestResponseHashKey = @"response-hash";

@interface MCTRequest () <NSURLSessionDelegate>

@property (nonatomic, readwrite) MCTRequestMethod requestMethod;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSDictionary *parameters;

@end

@implementation MCTRequest

+ (instancetype)requestWithMethod:(MCTRequestMethod)requestMethod
                        URLString:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
{
    MCTSession *session = [MCTSession sharedSession];
    NSURL *URL = session.serverURL;
    if (URLString.length)
    {
        URL = [NSURL URLWithString:URLString
                     relativeToURL:URL];
    }
    MCTRequest *request = [MCTRequest new];
    [request setShouldIgnoreServerTrustErrors:session.shouldIgnoreServerTrustErrors];
    [request setURL:URL];
    [request setParameters:parameters];
    [request setRequestMethod:requestMethod];
    return request;
}

- (NSString *)userAgent
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleIdentifier = bundle.infoDictionary[(__bridge NSString *)kCFBundleIdentifierKey];
    NSString *bundleVersion = bundle.infoDictionary[(__bridge NSString *)kCFBundleVersionKey];
    
    UIDevice *device = [UIDevice currentDevice];
    NSNumber *scale = @(UIScreen.mainScreen.scale);
    
    return [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%@)",
            bundleIdentifier,
            bundleVersion,
            device.model,
            device.systemVersion,
            scale];
}

- (NSString *)queryString
{
    NSMutableArray *queryArguments = [NSMutableArray new];
    [[self parameters] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *argument = [NSString stringWithFormat:@"%@=%@",
                              key, obj];
        [queryArguments addObject:argument];
        
    }];
    NSString *queryString = [queryArguments componentsJoinedByString:@"&"];
    return queryString;
}

- (NSString *)HTTPMethod
{
    switch (self.requestMethod)
    {
        case MCTRequestMethodGET:
            return @"GET";
            break;
        case MCTRequestMethodPOST:
            return @"POST";
            break;
        case MCTRequestMethodPUT:
            return @"PUT";
            break;
        case MCTRequestMethodDELETE:
            return @"DELETE";
            break;
    }
    return nil;
}

- (NSData *)HTTPBody
{
    if (self.parameters)
    {
        NSError *error = nil;
        NSData *body = [NSJSONSerialization dataWithJSONObject:self.parameters
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
#ifdef DEBUG
        NSString *JSONString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        NSLog(@"JSON Body: %@", JSONString);
#endif
        if (!error)
        {
            return body;
        }
    }
    return nil;
}

- (NSURLRequest *)preparedURLRequest
{
    NSMutableURLRequest *request = nil;
    if (self.URL)
    {
        request = [NSMutableURLRequest new];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:5.0];
        [request setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:[self HTTPMethod]];
        if (self.requestMethod != MCTRequestMethodGET)
        {
            [request setURL:[self URL]];
            [request setHTTPBody:[self HTTPBody]];
        }
        else
        {
            NSURLComponents *components = [NSURLComponents componentsWithString:self.URL.absoluteString];
            [components setQuery:[self queryString]];
            [request setURL:components.URL];
        }
    }
    return request;
}

- (NSURLSessionDataTask *)performRequestWithHandler:(void (^)(id responseObject, MCTRequestSummary *requestSummary))handler
{
    NSURLSessionDataTask *task = nil;
    NSURLRequest *request = self.preparedURLRequest;
    
    __block MCTRequestSummary *requestSummary = [MCTRequestSummary new];
    [requestSummary setRequest:request];

    NSString *requestString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    requestSummary.requestString = requestString;

    if (request)
    {
        id completion = ^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSError *JSONError = nil;
            id responseObject = nil;
            if (data.length)
            {
                [requestSummary setResponseHash:[data mct_SHA1String]];
                responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:(NSJSONReadingMutableLeaves |
                                                                          NSJSONReadingMutableContainers)
                                                                   error:&JSONError];
                
                if (responseObject)
                {
                    NSData *prettyPrinted = [NSJSONSerialization dataWithJSONObject:responseObject
                                                                            options:NSJSONWritingPrettyPrinted
                                                                              error:nil];
                    NSString *responseString = [[NSString alloc] initWithData:prettyPrinted
                                                                     encoding:NSUTF8StringEncoding];
                    [requestSummary setResponseString:responseString];
                }
                else
                {
                    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [requestSummary setResponseString:responseString];
                }
            }
            NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
            if (error || HTTPResponse.statusCode >= 400)
            {
                if (handler)
                {
                    if (!error)
                    {
                        NSString *description =  [NSHTTPURLResponse localizedStringForStatusCode:HTTPResponse.statusCode];
                        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description};
                        error = [NSError errorWithDomain:NSURLErrorDomain
                                                    code:HTTPResponse.statusCode
                                                userInfo:userInfo];
                    }
                    
                    [requestSummary setResponseError:error];
                    handler(responseObject, requestSummary);
                }
            }
            else
            {
                if (JSONError && handler)
                {
                    [requestSummary setResponseError:JSONError];
                    handler(responseObject, requestSummary);
                }
                else if (responseObject && handler)
                {
                    handler(responseObject, requestSummary);
                }
            }
            
        };
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                              delegate:self
                                                         delegateQueue:nil];
        task = [session dataTaskWithRequest:[self preparedURLRequest]
                          completionHandler:completion];
        [task resume];
    }
    return task;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if([[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if(self.shouldIgnoreServerTrustErrors)
        {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
        else
        {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    }
}

@end
