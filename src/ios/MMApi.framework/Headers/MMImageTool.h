//
//  MMImageTool.h
//  MMApi
//
//  Created by hoho on 2020/2/6.
//  Copyright © 2020 Hoho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MMFilterType) {
    MMFilterTypeBlackWhite,         //黑白模式
};

@interface MMImageTool : NSObject

/**
 图片处理滤镜
 
 @param image 需要处理的图片
 @param type  滤镜类型
 
 */
+ (UIImage *)mm_image:(UIImage *)image withFilterType:(MMFilterType)type;

+ (void)mm_image:(UIImage *)image
  withFilterType:(MMFilterType)type
        complete:(void (^)(UIImage *image))completeBlock;

@end

NS_ASSUME_NONNULL_END
