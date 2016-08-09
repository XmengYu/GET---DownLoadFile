//
//  LoadFile.h
//  GET方式下载文件
//
//  Created by xmy on 16/8/8.
//  Copyright © 2016年 xmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadFile : NSObject


/**
 *  下载
 *
 *  @param urlstring Url地址
 */
- (void)loadFileUrlString:(NSString *)urlstring;
/**
 *  暂停下载
 */
-(void)pasueDownload;
@end
