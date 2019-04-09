#import "Paperang.h"
#import <Cordova/CDVPlugin.h>
#import <MMApi/MMApi.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Paperang ()

@property (strong, nonatomic) NSString *base64Image;
@property (strong, nonatomic) NSString *macAddress;
@property (strong, nonatomic) CDVInvokedUrlCommand *scanCommand;

@end

@implementation Paperang

- (void) register:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        NSNumber *appId = [f numberFromString: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppId"]];
        NSString* appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppKey"];
        NSString* appSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppSecret"];

        // self.base64Image = [command.arguments objectAtIndex:0];
        // self.macAddress = [command.arguments objectAtIndex:1];

        [MMSharePrint registWithAppID:[appId longValue]
            AppKey: appKey
            andSecret: appSecret
            success:^{
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] 
                callbackId:command.callbackId];
            } fail:^(NSError *error) {
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] 
                callbackId:command.callbackId];
            }];
    }];
}

- (void) scan:(CDVInvokedUrlCommand*)command 
{
    [self.commandDelegate runInBackground:^{
            self.scanCommand = command;
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center addObserver:self selector:@selector(didDiscoverDevice:) 
                    name:MMDidDiscoverPeripheralNotification 
                    object:nil];
            [MMSharePrint startScan];
        
    }];
}

- (void)didDiscoverDevice:(NSNotification *)noti {
    if (self.scanCommand != nil) {
        NSLog(@"Did discover device %@",noti);
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        NSDictionary *dic = noti.object;
        CBPeripheral *pri = dic[@"peripheral"];
        NSLog(@"Peripheral: %@", pri);
        NSDictionary *device = [NSDictionary dictionaryWithObjectsAndKeys: @"name", pri.name, @"address", dic[@"MAC"], nil];
        NSArray *result = @[device];
        [center removeObserver:self
                name:MMDidDiscoverPeripheralNotification 
                object:nil];
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray: result] 
        callbackId:self.scanCommand.callbackId];
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Scan command is nil."]; 
        callbackId:command.callbackId];
    }
}

- (void)initNotification {
	// NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	// [center addObserver:self selector:@selector(didDiscoverDevice:) name:MMDidDiscoverPeripheralNotification object:nil];
	// [center addObserver:self selector:@selector(didConnectDevice:) name:MMDidConnectPeripheralNotification object:nil];
	// [center addObserver:self selector:@selector(statusDidChange:) name:MMDeviceExceptionStatusNotification object:nil];
	// [center addObserver:self selector:@selector(didFailConnectDevice:) name:MMDidFailToConnectPeripheralNotification object:nil];
}

- (void)didConnectDevice:(NSNotification *)noti {
	// NSLog(@"connect success");

    // NSURL *url = [NSURL URLWithString:self.base64Image];    
    // NSData *imageData = [NSData dataWithContentsOfURL:url];
    // UIImage *ret = [UIImage imageWithData:imageData];
    
    // [MMSharePrint printImage:ret printType:PrintTypeForImage completeSendData:^{
    //     [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] 
    //     callbackId:self.command.callbackId];
    // } fail:^(NSError *error){
    //     [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] 
    //     callbackId:self.command.callbackId];
    // }];
	
}

- (void)didFailConnectDevice:(NSNotification *)noti {
	// NSLog(@"Fail to connect to device %@", noti);
    // [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] 
    // callbackId:self.command.callbackId];
}

- (void)statusDidChange:(NSNotification *)noti {
	NSLog(@"Status change: %@", noti);
}


@end
