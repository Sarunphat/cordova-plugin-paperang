#import "Paperang.h"
#import <Cordova/CDVPlugin.h>
#import <MMApi/MMApi.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Paperang ()

@property (strong, nonatomic) NSString *base64Image;
@property (strong, nonatomic) NSString *macAddress;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) CDVInvokedUrlCommand *registerCommand;
@property (strong, nonatomic) CDVInvokedUrlCommand *scanCommand;
@property (strong, nonatomic) CDVInvokedUrlCommand *connectCommand;
@property (strong, nonatomic) CDVInvokedUrlCommand *disconnectCommand;
@property (strong, nonatomic) CDVInvokedUrlCommand *printCommand;

@end

@implementation Paperang

- (void) register:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        if (self.registerCommand == nil) {
            self.registerCommand = command;
            NSLog(@"Register commandId: %@", self.registerCommand.commandId);
            self.peripherals = [[NSMutableArray alloc] initWithCapacity: 1];
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            
            NSNumber *appId = [f numberFromString: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppId"]];
            NSString* appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppKey"];
            NSString* appSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PAPERANG_AppSecret"];

            [self initNotification];
            [MMSharePrint registWithAppID:[appId longValue]
                AppKey: appKey
                andSecret: appSecret
                success:^{
                    [MMSharePrint autoReconnect: NO];
                    NSLog(@"Register commandId Result: %@", self.registerCommand.commandId);
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"success"] 
                    callbackId:self.registerCommand.callbackId];
                    self.registerCommand = nil;
                } fail:^(NSError *error) {
                    NSLog(@"Register commandId Error: %@", self.registerCommand.commandId);
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Cannot init Bluetooth."] 
                    callbackId:self.registerCommand.callbackId];
                    self.registerCommand = nil;
                }
            ];
        } else {
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"App is registering."]
            callbackId:command.callbackId];
        }
    }];
}

- (void)initNotification {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(didDiscoverDevice:) name:MMDidDiscoverPeripheralNotification object:nil];
	[center addObserver:self selector:@selector(didConnectDevice:) name:MMDidConnectPeripheralNotification object:nil];
    [center addObserver:self selector:@selector(didFailConnectDevice:) name:MMDidFailToConnectPeripheralNotification object:nil];
	[center addObserver:self selector:@selector(didDisconnectDevice:) name:MMDidDisconnectPeripheralNotification object:nil];
	[center addObserver:self selector:@selector(didPrintFinished:) name:MMDidFinishPrintNotification object:nil];
}

- (void) scan:(CDVInvokedUrlCommand*)command 
{
    [self.commandDelegate runInBackground:^{
        self.scanCommand = command;
        NSLog(@"Scan commandId: %@", self.scanCommand.commandId);
	    [MMSharePrint startScan];
        // Create timer to stop scanning
        double delayInSeconds = 60.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(didStopScanning:) withObject:nil afterDelay: delayInSeconds];
        });
    }];
}
- (void) didDiscoverDevice:(NSNotification *)noti {
    if (self.scanCommand != nil) {
        NSDictionary *dic = noti.object;
        CBPeripheral *pri = dic[@"peripheral"];
        NSDictionary *device = [NSDictionary dictionaryWithObjectsAndKeys:  pri.name, @"name", dic[@"MAC"], @"address", nil];
        NSArray *result = @[device];
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys: @"scanning", @"state", result, @"deviceList", nil];
        [self addPeripheral: dic];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: ret];
        [pluginResult setKeepCallbackAsBool:YES];
        NSLog(@"Scan commandId Result: %@", self.scanCommand.commandId);
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.scanCommand.callbackId];
    } else {
        [MMSharePrint stopScan];
        NSLog(@"Scan commandId Result: %@", self.scanCommand.commandId);
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Scan command is nil."]
        callbackId:self.scanCommand.callbackId];
        self.scanCommand = nil
    }
}
- (void) didStopScanning: (id) sender {
    if (self.scanCommand != nil) {
        [MMSharePrint stopScan];
        NSArray *result = @[];
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys: @"finished", @"state", result, @"deviceList", nil];
        NSLog(@"Scan commandId Result: %@", self.scanCommand.commandId);
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: ret]
        callbackId:self.scanCommand.callbackId];
        self.scanCommand = nil
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
        self.connectCommand = command;
        NSLog(@"Connect commandId: %@", self.connectCommand.commandId);
        NSDictionary* dict = [self getPeripheral: [command.arguments objectAtIndex:0]];
        CBPeripheral *pri = dict[@"peripheral"];
        [MMSharePrint connectPeripheral:pri];
    }];
}
- (void)didConnectDevice:(NSNotification *)noti {
    if(self.connectCommand != nil) {
        NSLog(@"Connect commandId Result: %@", self.connectCommand.commandId);
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"success"]
        callbackId:self.connectCommand.callbackId];
        self.connectCommand = nil;
    } else {
        NSLog(@"Connect commandId Result: %@", self.connectCommand.commandId);
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Connect command is nil."]
        callbackId:self.connectCommand.callbackId];
        self.connectCommand = nil;
    }
}
- (void)didFailConnectDevice:(NSNotification *)noti {
    NSLog(@"Connect commandId Result: %@", self.connectCommand.commandId);
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Failed to connect to device."] 
    callbackId:self.connectCommand.callbackId];
    self.connectCommand = nil;
}

- (void) disconnect:(CDVInvokedUrlCommand*) command {
    [self.commandDelegate runInBackground:^{
        self.disconnectCommand = command;
        NSLog(@"Disconnect commandId: %@", self.disconnectCommand.commandId);
        [MMSharePrint disconnect];
    }];
}
- (void)didDisconnectDevice:(NSNotification *)noti {
    [self.commandDelegate runInBackground:^{
        NSLog(@"Disconnect commandId Result: %@", self.disconnectCommand.commandId);
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"success"] 
        callbackId:self.disconnectCommand.callbackId];
        self.disconnectCommand = nil;
    }];
}

- (void) print: (CDVInvokedUrlCommand*) command {
    [self.commandDelegate runInBackground:^{
        self.printCommand = command;
        NSLog(@"Print commandId: %@", self.printCommand.commandId);
        NSURL *url = [NSURL URLWithString:[command.arguments objectAtIndex:0]];    
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *ret = [UIImage imageWithData:imageData];
        NSLog(@"Print imageData: %@", imageData);
        
        [MMSharePrint printImage:ret printType:PrintTypeForImage completeSendData:^{
            NSLog(@"Print commandId Result: %@", self.printCommand.commandId);
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"success"] 
            callbackId:self.printCommand.callbackId];
        } fail:^(NSError *error){
            NSLog(@"Print commandId Result: %@", self.printCommand.commandId);
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Data send failed."]
            callbackId:self.printCommand.callbackId];
        }];
    }];
}

@end
