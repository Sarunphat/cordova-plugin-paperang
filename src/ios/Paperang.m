#import "Paperang.h"
#import <Cordova/CDVPlugin.h>
#import <MMApi/MMApi.h>

@interface Paperang ()

@property (strong, nonatomic) NSString *base64Image;
@property (strong, nonatomic) NSString *macAddress;
@property (strong, nonatomic) CDVInvokedUrlCommand *command;

@end

@implementation Paperang

- (void) register:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSNumber* appId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppId"];
        NSString* appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppKey"];
        NSString* appSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppSecret"];

        NSString* base64Image = [command.arguments objectAtIndex:0];
        NSString* macAddress = [command.arguments objectAtIndex:1];

        NSLog(@"%@ %@ %@", appId, appKey, appSecret);
        [MMSharePrint registWithAppID:[appId longValue]
            AppKey: appKey
            andSecret: appSecret
            success:^{
                self.command = command;
                self.base64Image = base64Image;
                self.macAddress = macAddress;
                [self initNotification];
                [MMSharePrint startScan];
            } fail:^(NSError *error) {
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] 
                callbackId:command.callbackId];
            }];
    }];
}

- (void)initNotification {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(didDiscoverDevice:) name:MMDidDiscoverPeripheralNotification object:nil];
	[center addObserver:self selector:@selector(didConnectDevice:) name:MMDidConnectPeripheralNotification object:nil];
	[center addObserver:self selector:@selector(statusDidChange:) name:MMDeviceExceptionStatusNotification object:nil];
	[center addObserver:self selector:@selector(didFailConnectDevice:) name:MMDidFailToConnectPeripheralNotification object:nil];
}

- (void)didDiscoverDevice:(NSNotification *)noti {
	NSLog(@"Did discover device %@",noti);
	NSDictionary *dic = noti.object;
	CBPeripheral *pri = dic[@"peripheral"];
	NSLog(@"Peripheral: %@", pri);
	//replace @"00:15:83:BD:8A:D8" with your device mac
	if ([dic[@"MAC"] isEqualToString:self.macAddress]) {
		[MMSharePrint connectPeripheral:pri];
	}
}

- (void)didConnectDevice:(NSNotification *)noti {
	NSLog(@"connect success");

    NSURL *url = [NSURL URLWithString:self.base64Image];    
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *ret = [UIImage imageWithData:imageData];
    
    [MMSharePrint printImage:ret printType:PrintTypeForImage completeSendData:^{
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] 
        callbackId:self.command.callbackId];
    } fail:^(NSError *error){
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] 
        callbackId:self.command.callbackId];
    }];
	
}

- (void)didFailConnectDevice:(NSNotification *)noti {
	NSLog(@"Fail to connect to device %@", noti);
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] 
    callbackId:self.command.callbackId];
}

- (void)statusDidChange:(NSNotification *)noti {
	NSLog(@"Status change: %@", noti);
}


@end
