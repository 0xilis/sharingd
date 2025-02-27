//
//  AKAppleIDSession.h
//  sharingd
//
//  Created by Snoolie Keffaber on 2025/02/25.
//

#ifndef AKAppleIDSession_h
#define AKAppleIDSession_h

@interface AKAppleIDSession : NSObject
- (id)_anisetteController;
- (void)_handleURLResponse:(id)arg1 forRequest:(id)arg2 withCompletion:(CDUnknownBlockType)arg3;
- (void)_generateAppleIDHeadersForRequest:(id)arg1 withCompletion:(CDUnknownBlockType)arg2;
- (void)handleResponse:(id)arg1 forRequest:(id)arg2 shouldRetry:(_Bool *)arg3;
- (id)appleIDHeadersForRequest:(id)arg1;
- (void)URLSession:(id)arg1 task:(id)arg2 getAppleIDHeadersForResponse:(id)arg3 completionHandler:(CDUnknownBlockType)arg4;
- (id)relevantHTTPStatusCodes;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)initWithIdentifier:(id)arg1;
@end

#endif /* AKAppleIDSession_h */
