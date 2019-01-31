#import "Paperang.h"
#import <Cordova/CDVPlugin.h>

@implementation Paperang

- (void)register:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Register is called in iOS platform.");
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSNumber* appId = [command.arguments objectAtIndex:0];
        NSString* appKey = [command.arguments objectAtIndex:1];
        NSString* appSecret = [command.arguments objectAtIndex:2];

        if (appId != nil) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:appId];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
