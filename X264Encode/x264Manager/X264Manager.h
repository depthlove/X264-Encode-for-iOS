//
//  X264Manager.h
//  X264Encode
//
//  Created by sunminmin on 15/8/27.
//  Copyright (c) 2015年 suntongmian@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>


@interface X264Manager : NSObject

/*
 * 设置编码后文件的保存路径
 */
- (void)setFileSavedPath:(NSString *)path;

/*
 * 设置X264
 */
- (void)setX264Resource;

/*
 * 将CMSampleBufferRef格式的数据编码成h264并写入文件
 */
- (void)encoderToH264:(CMSampleBufferRef)sampleBuffer;

/*
 * 释放资源
 */
- (void)freeX264Resource;

@end
