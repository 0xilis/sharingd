//
//  SDAppleIDServerTask.h
//  sharingd
//
//  Created by Snoolie Keffaber on 2025/02/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDAppleIDServerTask : NSObject
@property(retain, nonatomic) NSURLRequest *urlRequest;
@property(readonly, nonatomic) long long type;
@property(retain, nonatomic) NSURLSession *session;
@property(readonly, nonatomic) NSDictionary *taskInfo;
@property(nonatomic) _Bool invalidated;
@property(retain, nonatomic) NSString *gsToken;
@property(readonly, nonatomic) NSString *appleID;
@property(nonatomic) _Bool activated;
@property(copy, nonatomic) void(^responseHandler)(id, NSError *);
@property(retain, nonatomic) NSObject<OS_dispatch_queue> *dispatchQueue;

- (instancetype)initWithType:(long long)type appleID:(NSString *)appleID info:(NSDictionary *)info;
- (void)_callResponseHandlerWithInfo:(id)info errorInfo:(NSDictionary<NSErrorUserInfoKey, id> *)errorInfo error:(NSInteger)error;
- (void)_handleTaskResponse:(id)a3 withData:(id)a4 error:(int)a5;
- (void)_urlRequestWithCompletion:(CDUnknownBlockType)arg1;
@end

int SDAppleIDCreateComboTokenBase64(NSString *str0, NSString *str1, NSString **result);

NS_ASSUME_NONNULL_END
