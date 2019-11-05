#import <Cordova/CDVPlugin.h>

@interface Paperang : CDVPlugin

- (void)register:(CDVInvokedUrlCommand*) command;
- (void)scan:(CDVInvokedUrlCommand*) command;
- (void)connect:(CDVInvokedUrlCommand*) command;
- (void)disconnect:(CDVInvokedUrlCommand*) command;
- (void)print:(CDVInvokedUrlCommand*) command;
- (void)clearDeviceList:(CDVInvokedUrlCommand*) command;
- (void) getCurrentDeviceList:(CDVInvokedUrlCommand *) command;

@end
