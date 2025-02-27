//
//  SDAppleIDMutableURLRequest.h
//  sharingd
//
//  Created by Snoolie Keffaber on 2025/02/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDAppleIDMutableURLRequest : NSMutableURLRequest
- (instancetype)initWithURL:(NSURL *)url gsToken:(NSString *)gsToken;
@end

NS_ASSUME_NONNULL_END
