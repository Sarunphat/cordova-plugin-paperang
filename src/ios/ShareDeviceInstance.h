//
//  ShareDeviceInstance.h
//  ATR DEV
//
//  Created by Sarunphat Pisutvimol on 5/11/2562 BE.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareDeviceInstance : NSObject
+ (ShareDeviceInstance *)sharedInstance;

@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic, retain) NSMutableArray *allDevice;

@end
NS_ASSUME_NONNULL_END