#import <Cordova/CDVPlugin.h>

@interface Paperang : CDVPlugin

- (void)register:(CDVInvokedUrlCommand*) command;
- (void)scan:(CDVInvokedUrlCommand*) command;
- (void)cennect:(CDVInvokedUrlCommand*) command;
- (void)disconnect:(CDVInvokedUrlCommand*) command;

@end
