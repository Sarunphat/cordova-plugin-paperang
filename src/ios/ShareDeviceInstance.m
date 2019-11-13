//
//  ShareDeviceInstance.m
//  ATR DEV
//
//  Created by Sarunphat Pisutvimol on 5/11/2562 BE.
//

#import "ShareDeviceInstance.h"

@implementation ShareDeviceInstance
+ (ShareDeviceInstance *)sharedInstance
{
	static ShareDeviceInstance *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[ShareDeviceInstance alloc] init];
		// Do any other initialisation stuff here
	});
	return sharedInstance;
}
- (instancetype) init {
	if ((self = [super init])) {
		self.peripherals = [[NSMutableArray alloc] init];
		self.allDevice = [[NSMutableArray alloc] init];
	}
	return self;
}

@end