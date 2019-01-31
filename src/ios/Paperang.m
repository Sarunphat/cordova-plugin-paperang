#import "Paperang.h"
#import <Cordova/CDVPlugin.h>

@implementation Paperang

- (void)register:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSInteger* appId = [command.arguments objectAtIndex:0];
    NSInteger* appKey = [command.arguments objectAtIndex:1];
    NSInteger* appSecret = [command.arguments objectAtIndex:2];

    if (appId != nil && [appId length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
