//
//  MMSharePrint.h
//  MMApi
//
//  Created by hoho on 2017/10/25.
//  Copyright © 2017年 Hoho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CBPeripheral;

typedef NS_ENUM(NSInteger, PrintType) {
    PrintTypeForImage,      //模拟灰度打印模式
    PrintTypeForText        //黑白二打印模式
};

/**
 发现Paperang设备通知，带有设备对象
 {
    @"peripheral":peripheral,
    @"MAC":MAC,
    @"RSSI":RSSI
 }
 */
UIKIT_EXTERN NSNotificationName const MMDidDiscoverPeripheralNotification;
/**
 将要连接Paperang设备通知
 {
    @"peripheral":peripheral
 }
 */
UIKIT_EXTERN NSNotificationName const MMWillConnectPeripheralNotification;
/**
 连接上Paperang设备通知
 {
    @"peripheral":peripheral,
    @"isUserConnect":@(YES)         判断是用户主动连接（YES) 自动连接（NO)
 }
 */
UIKIT_EXTERN NSNotificationName const MMDidConnectPeripheralNotification;
/**
 连接Paperang设备失败通知
 {
    @"code":@(313),
    @"snCode":snCode,
    @"error":@"未联网激活设备"
 }
 code:
    -1  未识别设备
    -2  禁止连接设备
    -3  连接超时
    313 需要联网激活设备
 */
UIKIT_EXTERN NSNotificationName const MMDidFailToConnectPeripheralNotification;
/**
 断开Paperang设备连接通知
 {
    @"peripheral":peripheral,
    @"isUserDisconnect":@(YES)       判断是用户主动断开（YES) 异常断开（NO)
    @"error":errorStr               无错误为空字符串
 }
 */
UIKIT_EXTERN NSNotificationName const MMDidDisconnectPeripheralNotification;

/**
 将要发送数据通知
 */
UIKIT_EXTERN NSNotificationName const MMWillSendDataNotification;

/**
 发送数据完成通知
 */
UIKIT_EXTERN NSNotificationName const MMDidSendDataNotification;

/**
 打印完成通知
 */
UIKIT_EXTERN NSNotificationName const MMDidFinishPrintNotification;

/**
 设备异常数据：
 {
    @"code":exceptionCode
    @"errorStr"errorDescription
 }
 code:
    -1 低电量
    -2 缺纸
    -3 过热
    -4 设备开盖
 */
UIKIT_EXTERN NSNotificationName const MMDeviceExceptionStatusNotification;

@interface MMSharePrint : NSObject

/**
 获取当前SDK版本号

 @return SDK版本号
 */
+ (NSString *)getSdkVersion;

/**
 注册MMAPI SDK

 @param appId 开发者应用Id
 @param appKey 开发者AppKey
 @param secret 开发者secret
 */
+ (void)registWithAppID:(long)appId
                 AppKey:(NSString *)appKey
              andSecret:(NSString *)secret;

/**
 注册MMAPI SDK
 
 @param appId 开发者应用Id
 @param appKey 开发者AppKey
 @param secret 开发者secret
 @param success 验证成功回调
 @param fail 失败回调
 */

+ (void)registWithAppID:(long)appId
                 AppKey:(NSString *)appKey
              andSecret:(NSString *)secret
                success:(void (^)(void))success
                   fail:(void (^) (NSError *error))fail;

/**
 获取开发者验证状态

 @return 开发者账号验证状态
 */
+ (BOOL)getAuthorizationStatus;

/**
 设置连接设备限制，由官方提供，空字符串可联所有喵宝机器

 @param makerUser 官方提供限制字符串
 */
+ (void)configMakerUser:(NSString *)makerUser;

/**
 设置是否显示log

 @param showLog log开关
 */
+ (void)debugLog:(BOOL)showLog;

/**
 设置是否自动重连设备
 
 @param autoReconnect 自动重连开关
 */
+ (void)autoReconnect:(BOOL)autoReconnect;

/**
 获取设备连接情况

 @return YES 已经连接   NO 未连接设备
 */
+ (BOOL)getDeviceConnectStatus;

/**
开始搜索蓝牙
 */
+ (void)startScan;

/**
停止搜索蓝牙
 */
+ (void)stopScan;

/**
 获取上次连接设备的UUID

 @return 上次连接设备的UUID
 */
+ (NSString *)getLastPeripheralUUID;
/**
 连接设备

 @param peripheral 设备对象
 */
+ (void)connectPeripheral:(CBPeripheral *)peripheral;

/**
 断开连接
 */
+ (void)disconnect;

/**
 分享图片数据

 @param data 图片数据
 */
+ (void)mmSharePrintData:(NSData *)data;

/**
 分享图片对象

 @param image 图片对象
 */
+ (void)mmSharePrintImage:(UIImage *)image;

/**
 打印图片对象

 @param image 图片对象
 @param type 打印类型，详见PrintType
 @param complete 开始发送数据回调
 @param fail 发送数据失败回调
 */
+ (void)printImage:(UIImage *)image
         printType:(PrintType)type
  completeSendData:(void (^)(void))complete
              fail:(void (^)(NSError *error))fail;

@end
