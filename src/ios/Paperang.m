#import "Paperang.h"
#import <Cordova/CDVPlugin.h>
#import <MMApi/MMApi.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Paperang ()

@property (strong, nonatomic) NSString *base64Image;
@property (strong, nonatomic) NSString *macAddress;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) CDVInvokedUrlCommand *scanCommand;
@property (strong, nonatomic) CDVInvokedUrlCommand *connectCommand;

@end

@implementation Paperang

- (void) register:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        self.peripherals = [[NSMutableArray alloc] initWithCapacity: 1];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        NSNumber *appId = [f numberFromString: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppId"]];
        NSString* appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppKey"];
        NSString* appSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppSecret"];

        // self.base64Image = [command.arguments objectAtIndex:0];
        // self.macAddress = [command.arguments objectAtIndex:1];
        [self initNotification];
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

- (void)initNotification {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(didDiscoverDevice:) name:MMDidDiscoverPeripheralNotification object:nil];
	[center addObserver:self selector:@selector(didConnectDevice:) name:MMDidConnectPeripheralNotification object:nil];
    [center addObserver:self selector:@selector(didFailConnectDevice:) name:MMDidFailToConnectPeripheralNotification object:nil];
	[center addObserver:self selector:@selector(didFailConnectDevice:) name:MMDidFailToConnectPeripheralNotification object:nil];
	[center addObserver:self selector:@selector(didPrintNotification:) name:MMDidFinishPrintNotification object:nil];
}

- (void) scan:(CDVInvokedUrlCommand*)command 
{
    [self.commandDelegate runInBackground:^{
        self.scanCommand = command;
	    [MMSharePrint startScan];
    }];
}

- (void) didDiscoverDevice:(NSNotification *)noti {
    if (self.scanCommand != nil) {
        NSDictionary *dic = noti.object;
        CBPeripheral *pri = dic[@"peripheral"];
        NSDictionary *device = [NSDictionary dictionaryWithObjectsAndKeys:  pri.name, @"name", dic[@"MAC"], @"address", nil];
        NSArray *result = @[device];
        [MMSharePrint stopScan];
        [self addPeripheral: dic];
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray: result] 
        callbackId:self.scanCommand.callbackId];
        self.scanCommand = nil;
    } else {
        [MMSharePrint stopScan];
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Scan command is nil."]
        callbackId:self.scanCommand.callbackId];
        self.scanCommand = nil;
    }
}

- (void) addPeripheral:(NSDictionary *) peri {
    bool isAdded = false;
    for (NSDictionary* p in self.peripherals) {
        if ([p[@"MAC"] isEqualToString: peri[@"MAC"]]) {
            isAdded = true;
            break;
        }
    }
    if (!isAdded) {
        [self.peripherals addObject:peri];
    }
}

- (NSDictionary*) getPeripheral: (NSString *) mac {
    for (NSDictionary* p in self.peripherals) {
        if ([p[@"MAC"] isEqualToString: mac]) {
            return p;
        }
    }
    return nil;
}

- (void) connect:(CDVInvokedUrlCommand*) command {
    [self.commandDelegate runInBackground:^{
        self.macAddress = [command.arguments objectAtIndex:0];
        self.scanCommand = command;

    }];
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

@end
