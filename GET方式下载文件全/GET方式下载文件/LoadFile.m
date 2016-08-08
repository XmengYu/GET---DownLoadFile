//
//  LoadFile.m
//  GET方式下载文件
//
//  Created by xmy on 16/8/8.
//  Copyright © 2016年 xmy. All rights reserved.
//

#import "LoadFile.h"
/**
 问题:
 1. 下载,总共的大小,已经收到的data的大小,会有一个峰值,内存可能会承载不了而崩溃
 2. 内存暴涨的问题.在接收到数据的代理方法,去将数据写入到指位置就可以了
 */
@interface LoadFile ()<NSURLConnectionDataDelegate>

/**
 *  要下载文件的实际大小
 */
@property(assign,nonatomic)long long expectedLength;
/**
 *  下载完成后的大小
 */
@property(assign,nonatomic)long long currentLength;
/**
 *  定义一个可变的二进制data ,用于接收每一次下载的数据大小
 */
@property(strong,nonatomic)NSMutableData *dataM;


@end

@implementation LoadFile
- (void)loadFileUrlString:(NSString *)urlstring;
{
    NSURL *url = [NSURL URLWithString:urlstring];
    
    NSURLRequest *request= [NSURLRequest requestWithURL:url];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        
//        if (connectionError != nil || data.length == 0) {
//            NSLog(@"错误:%@",connectionError);
//            return;
//        }
//        [data writeToFile:@"/Users/heima/Desktop/sougou.zip" atomically:true];
//    }];
}
/**
 *
 */
#pragma mark - 代理方法

/**
 *  已经收到响应的时候就会调用这个方法
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    self.expectedLength = response.expectedContentLength;
    NSLog(@"%@",response);
}
/**
 已经收到数据的时候才会调用这个方法
 *
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    self.currentLength = data.length;
    //计算进度
    float proceress = (float)self.currentLength / self.expectedLength;
    NSLog(@"收到的数据 %f %lu",proceress,data.length);
    
    [self.dataM appendData:data];
}
/**
 这次连接结束的时候会调用这个方法
 *
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSLog(@"下载完成");
    
    //在下载响应完成时,将该二进制数据保存到指定的位置,公司开发的话会保存到沙盒,
    [self.dataM writeToFile:@"/Users/xmy/Desktop/sougou.zip" atomically:true];
    
}
/**
 *  下载失败的方法
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"下载失败!%@",error);
}

#pragma mark - 懒加载

-(NSMutableData *)dataM{
    
    if(_dataM == nil){
        
        _dataM = [NSMutableData data];
        
    }
    return _dataM;
}
@end
