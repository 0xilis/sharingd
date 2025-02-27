//
//  SDAppleIDServerTask.m
//  sharingd
//
//  Created by Snoolie Keffaber on 2025/02/25.
//

#import "SDAppleIDServerTask.h"
#import <Security/Security.h>
#import "AuthKit/AKAppleIDSession.h"
#import "SDAppleIDMutableURLRequest.h"

@interface NSURLSessionConfiguration (ughhh)
- (void)set_appleIDContext:(id)arg1; // these might be in __NSCFURLSessionConfiguration pre-iOS 17 instead of directly in NSURLSessionConfiguration
- (void)set_tlsTrustPinningPolicyName:(id)arg1;
@end

extern const CFStringRef kSecPolicyNameAppleAIDCService; // In Security.framework
extern const NSErrorDomain SFAppleIDErrorDomain; // In Sharing.framework

@implementation SDAppleIDServerTask
- (instancetype)initWithType:(long long)type appleID:(NSString *)appleID info:(NSDictionary *)info {
    self = [super init]; // Call to the superclass initializer
    if (self) {
        _appleID = appleID;
        // Set up the dispatch queue
        _dispatchQueue = dispatch_queue_create("com.apple.SDAppleIDServerTask", DISPATCH_QUEUE_SERIAL);
        _taskInfo = info;
        _type = type;
        
        // Initialize session configuration
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // Set timeout interval and TLS trust pinning policy
        [config setTimeoutIntervalForResource:3600.0]; // 1 hour timeout
        [config set_tlsTrustPinningPolicyName:kSecPolicyNameAppleAIDCService];
        
        // Create a new AKAppleIDSession for context
        AKAppleIDSession *appleIDSession = [[AKAppleIDSession alloc] initWithIdentifier:@"com.apple.coreservices.appleidauthagent"];
        
        // Set session properties
        [config setWaitsForConnectivity:YES];
        [config set_appleIDContext:appleIDSession];
        
        // Create session with the configuration
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    
    return self;
}
- (void)activate {
    // Get the dispatch queue
    NSObject *dispatchQueue = self->_dispatchQueue;
    
    // Define the block to be executed asynchronously
    void (^block)(void) = ^{
        [self _activate];
    };
    
    // Dispatch the block to the specified dispatch queue
    dispatch_async((dispatch_queue_t)dispatchQueue, block);
}
- (void)_callResponseHandlerWithInfo:(id)info errorInfo:(NSDictionary<NSErrorUserInfoKey, id> *)errorInfo error:(NSInteger)error {
    
    // Assert that we are on the correct dispatch queue
    dispatch_assert_queue((dispatch_queue_t)self->_dispatchQueue);
    
    // Call the responseHandler method (getter) to check if a response handler exists
    id responseHandler = [self responseHandler];
    
    // If a response handler exists, process the response
    if (responseHandler) {
        id errorToReturn = nil;
        
        // If there's an error, create an NSError object
        if (error) {
            errorToReturn = [NSError errorWithDomain:SFAppleIDErrorDomain code:error userInfo:errorInfo];
        }
        
        // Call the response handler with the retained info and error (if any)
        void (^handler)(id, NSError *) = responseHandler;
        handler(info, errorToReturn);
        
        // Clear the response handler after use
        [self setResponseHandler:nil];
    }
    
    // There's another check but i don't understand it so not leaving it here
}
- (void)_callResponseHandlerWithInfo:(id)info error:(NSInteger)error {
    [self _callResponseHandlerWithInfo:info errorInfo:nil error:error];
}
- (BOOL)_isTaskInfoValid {
    // Ensure we are on the correct dispatch queue
    dispatch_assert_queue((dispatch_queue_t)self->_dispatchQueue);
    
    // Get the taskInfo
    NSDictionary *taskInfo = [self taskInfo];
    NSUInteger taskInfoCount = [taskInfo count];
    
    // Check the task type
    switch ([self type]) {
        case 0:
        case 1: {
            if (taskInfoCount != 1) {
                return NO;
            }
            
            // Check for "csr" or "certificateToken" keys in taskInfo
            NSString *key = ([self type] == 0) ? @"csr" : @"certificateToken";
            NSString *value = [taskInfo objectForKey:key];
            
            if (!value || ![value isKindOfClass:[NSString class]]) {
                return NO;
            }
            break;
        }
        
        case 2: {
            if (taskInfoCount != 2) {
                return NO;
            }
            
            // Check for "serialNumber" and "clientAidvrId" keys
            NSString *serialNumber = taskInfo[@"serialNumber"];
            NSString *clientAidvrId = taskInfo[@"clientAidvrId"];
            
            if (!serialNumber || ![serialNumber isKindOfClass:[NSString class]] ||
                !clientAidvrId || ![clientAidvrId isKindOfClass:[NSString class]]) {
                return NO;
            }
            break;
        }
        
        case 3: {
            if (taskInfoCount != 1) {
                return NO;
            }
            
            // Hope this is right?
            for (NSString *item in taskInfo) {
                if (!item) {
                    return NO;
                }
                if (![item isKindOfClass:[NSString class]]) {
                    return NO;
                }
            }
            
            // Check for "emails" and "phones" keys
            NSArray *emails = taskInfo[@"emails"];
            if (emails && ![emails isKindOfClass:[NSArray class]] && [emails count] != 1) {
                return NO;
            }
            
            NSArray *phones = taskInfo[@"phones"];
            if (phones && (![phones isKindOfClass:[NSArray class]] || [phones count] != 1)) {
                return NO;
            }
            break;
        }
        
        default:
            return NO;
    }

    return YES;
}
- (void)_urlWithCompletion:(void (^)(NSURL *url, NSError *error))completion {
    // Retain the completion block
    void (^completionHandler)(NSURL *url, NSError *error) = [completion copy];

    // Ensure we're on the correct dispatch queue
    dispatch_assert_queue((dispatch_queue_t)self->_dispatchQueue);

    if (completionHandler) {
        // Some check is here, not implemented rn

        // Get the task type
        long long taskType = [self type];

        // Dispatch the work to a background queue
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        // Define a block to handle the async task
        void (^asyncBlock)(void) = ^{
            // TODO: Implement block here
        };

        // Execute the block asynchronously
        dispatch_async(queue, asyncBlock);

    } else {
        // Some check is here, not implemented rn
    }
}
- (void)_handleURLIsAvailable:(NSURL *)url error:(int)error completion:(void (^)(SDAppleIDMutableURLRequest *request, int error))completion {
    // Retain the provided parameters
    // I am not 100% sure if the 1st argument for completion is the request or the gsToken
    void (^completionHandler)(SDAppleIDMutableURLRequest *request, int error) = [completion copy];

    // Ensure we're on the correct dispatch queue
    dispatch_assert_queue((dispatch_queue_t)self->_dispatchQueue);

    NSString *token = nil;
    NSDictionary *taskInfo = nil;
    NSData *requestBody = nil;
    SDAppleIDMutableURLRequest *request;

    // If URL is not nil and no error is passed (error == 0)
    if (url && error == 0) {
        // Retrieve the gsToken (global session token)
        token = [self gsToken];
        
        if (token) {
            // Create a new request using the URL and token
            request = [[SDAppleIDMutableURLRequest alloc] initWithURL:url gsToken:token];
            
            // Get the task info associated with the request
            taskInfo = [self taskInfo];
            
            if (taskInfo) {
                // Serialize the task info to JSON for the request body
                NSError *jsonError = nil;
                requestBody = [NSJSONSerialization dataWithJSONObject:taskInfo options:0 error:&jsonError];
                
                if (requestBody) {
                    // Set the HTTP body for the request
                    [request setHTTPBody:requestBody];
                } else {
                    // TODO: Error logging
                }
            } else {
                // If task info is not available, return an error code
                error = 4294960534LL;
            }
        } else {
            // If gsToken is not available, return an error code
            error = 4294960587LL;
        }
    }
    
    // Call the completion handler with the request and the error
    if (completionHandler) {
        completionHandler(request, error);
    }
}
- (void)_handleURLRequestIsAvailable {
    NSURLSession *session;
    dispatch_assert_queue((dispatch_queue_t)self->_dispatchQueue);
    NSURLRequest *request = [self urlRequest];
    if (request) {
        session = self->_session;
        [session dataTaskWithRequest:[self urlRequest] completionHandler:^(NSData *data, NSURLResponse *response, NSError *err){
            dispatch_async((dispatch_queue_t)self->_dispatchQueue, ^(){
                [self _handleTaskResponse:response withData:data error:err];
            });
        }];
    }
}
- (void)_handleGSTokenIsAvailable
{
    // Assert that we're on the correct dispatch queue
    dispatch_assert_queue((dispatch_queue_t)self->_dispatchQueue);
    
    // Attempt to retrieve the GS token
    id gsToken = [self gsToken];
    if (gsToken) {
        // Proceed to make URL request with completion callback
        [self _urlRequestWithCompletion:^(NSURLRequest *request, id arg2, NSInteger code){
            // Ensure we're on the correct dispatch queue
            dispatch_assert_queue((dispatch_queue_t)self->_dispatchQueue);
            
            // If code is 0 (no error), proceed
            if (!code) {
                // Set URL request and handle it
                [self setUrlRequest:request];
                [self _handleURLRequestIsAvailable];
            } else {
                // If code is non-zero (error), call response handler with error
                [self _callResponseHandlerWithInfo:nil error:code];
            }

            return request;
        }];
    } else {
        // Call response handler with error if GS token is unavailable
        [self _callResponseHandlerWithInfo:nil error:4294960587LL];
    }
}
- (void)_sendRequest {
    //TODO: THIS IS DEFINETELY NOT ACCURATE...
    // Retrieve the Apple ID from the current task
    NSString *appleID = [self appleID];
    
    // Get the dispatch queue from the instance variable
    NSObject *dispatchQueue = self->_dispatchQueue;
    
    // I have no idea why this is a block and not just in the code
    void (^block)(NSString*,NSString*,int) = ^(NSString *str0, NSString *str1, int something){
        // Retain the arguments to ensure they stay alive during the block execution
        
        // Ensure the block is executed on the correct queue
        dispatch_assert_queue((dispatch_queue_t)self->_dispatchQueue);
        
        // Check if the task is already cancelled (TODO: Implement this check)
        
        // Check if there was an error passed in something
        if (something) {
            // Log the error
            
            // Handle the response with the error
            [self _callResponseHandlerWithInfo:nil error:0x31204];
            return;
        }
        
        // Create a combo token from the provided arguments
        NSString *comboToken = nil;
        SDAppleIDCreateComboTokenBase64(str0, str1, &comboToken);
        
        // If the combo token was successfully created, set it and handle the response
        if (comboToken) {
            [self setGsToken:comboToken];
            [self _handleGSTokenIsAvailable];
        }
    };
    
    // Execute the block on the dispatch queue
    block(appleID, dispatchQueue, 0);
}
- (void)_activate {
    // Assert that we're on the correct dispatch queue
    dispatch_assert_queue((dispatch_queue_t)self->_dispatchQueue);

    // Check if already activated
    if (self->_activated) {
        // log
    } else {
        // If the task is invalidated, handle this case
        if (self->_invalidated) {
            // log
            uint64_t errorCode = 4294960573LL;  // Set error code
            // Call response handler with error code if task is invalidated
            [self _callResponseHandlerWithInfo:nil error:errorCode];
        }
        else {
            //log

            // If task info is valid, send the request and activate
            if ([self _isTaskInfoValid]) {
                [self _sendRequest];  // Send the request
                self->_activated = YES;  // Mark as activated
                return;
            }

            uint64_t errorCode = 4294960591LL;  // Set error code for invalid task info

            // Call response handler with error code if task info is invalid
            [self _callResponseHandlerWithInfo:nil error:errorCode];
        }
    }
}
@end

int SDAppleIDCreateComboTokenBase64(NSString *str0, NSString *str1, NSString **result) {
    // Retain arguments
    NSString *comboString = nil;
    NSData *data = nil;
    NSString *base64String = nil;
    
    // Error handling defaults
    int error = -6705;

    // Check if the strings are nil
    if (!str0 || !str1) {
        return error;
    }

    // Create combo string using both arguments
    comboString = [NSString stringWithFormat:@"%@:%@", str0, str1];
    if (!comboString) {
        return error;
    }

    // Convert combo string to NSData
    data = [comboString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return error;
    }

    // Encode data in Base64
    base64String = [data base64EncodedStringWithOptions:0];
    if (!base64String) {
        return error;
    }

    // If base64 encoding is successful, return the result
    if (result) {
        // Store the result in the output variable
        *result = base64String;
    }

    return 0;
}
