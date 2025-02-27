//
//  AKDevice.h
//  sharingd
//
//  Created by Snoolie Keffaber on 2025/02/25.
//

#ifndef AKDevice_h
#define AKDevice_h

@interface AKDevice : NSObject
+ (id)deviceSpecificLocalizedStringWithKey:(id)arg1;
+ (id)_buildNumber;
+ (id)_osVersion;
+ (id)_osName;
+ (id)_hardwareModel;
+ (id)_generateServerFriendlyDescription;
+ (id)_lookUpCurrentUniqueDeviceID;
+ (id)_lookUpCurrentEnclosureColor;
+ (id)_lookUpCurrentColor;
+ (id)deviceWithSerializedData:(id)arg1;
+ (_Bool)supportsSecureCoding;
+ (id)currentDevice;
@property(copy) NSString *serverFriendlyDescription;
@end

#endif /* AKDevice_h */
