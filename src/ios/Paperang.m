#import "Paperang.h"
#import <Cordova/CDVPlugin.h>

@implementation Paperang

- (void)register:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSInteger* appId = [command.arguments objectAtIndex:0];
        NSString* appKey = [command.arguments objectAtIndex:1];
        NSString* appSecret = [command.arguments objectAtIndex:2];

        if (appId != nil && [appId length] > 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:appId];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
