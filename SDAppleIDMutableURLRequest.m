//
//  SDAppleIDMutableURLRequest.m
//  sharingd
//
//  Created by Snoolie Keffaber on 2025/02/25.
//

#import "SDAppleIDMutableURLRequest.h"
#import "AuthKit/AKDevice.h"

int gethostuuid(unsigned char *uuid_buf, const struct timespec *timeoutp); // In CoreFoundation

@implementation SDAppleIDMutableURLRequest
- (instancetype)initWithURL:(NSURL *)url gsToken:(NSString *)gsToken {
    // Call the superclass initializer to initialize the object with the URL
    self = [super initWithURL:url];
    if (self) {
        // Disable handling of cookies
        [self setHTTPShouldHandleCookies:NO];

        // Set the HTTP method to POST
        [self setHTTPMethod:@"POST"];

        // Set the content type header to application/json
        [self setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

        // Add custom headers if needed
        static NSString *serverFriendlyDescription;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // Client Info Initialization Block
            AKDevice *currentDevice = [AKDevice currentDevice];
            serverFriendlyDescription = [currentDevice serverFriendlyDescription];
        });
        [self setValue:serverFriendlyDescription forHTTPHeaderField:@"X-Mme-Client-Info"];

        static NSString *uuidString;
        static dispatch_once_t onceToken2;
        dispatch_once(&onceToken2, ^{
            // Initialize device-specific info here, if required
            CFUUIDBytes uuidBytes;
            struct timespec timeout = {0, 0};   // Infinite timeout for gethostuuid()
            if (!gethostuuid((unsigned char *)&uuidBytes, &timeout)) {
                NSUUID *deviceUUID = [[NSUUID alloc] initWithUUIDBytes:(unsigned char *)&uuidBytes];
                if (deviceUUID) {
                    uuidString = [deviceUUID UUIDString];
                } else {
                    // Error logged here
                }
            } else {
                //TODO: Implement error logging
            }
        });
        [self setValue:uuidString forHTTPHeaderField:@"X-Mme-Device-ID"];

        // Set the GS token header
        [self setValue:gsToken forHTTPHeaderField:@"X-Apple-GS-Token"];
    }

    return self;
}
@end
