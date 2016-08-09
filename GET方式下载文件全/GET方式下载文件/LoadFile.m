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
@interface LoadFile () <NSURLConnectionDataDelegate>

/**
 *  要下载文件的实际大小
 */
@property(assign, nonatomic) long long expectedLength;
/**
 *  下载完成后的大小
 */
@property(assign, nonatomic) long long currentLength;
/**
    第一种方式:
 *  定义一个可变的二进制data ,用于接收每一次下载的数据大小
 */
//@property(strong,nonatomic)NSMutableData *dataM;

/**
 *  第三种方式:输出流
 */
@property(strong, nonatomic) NSOutputStream *stream;

/**
 *  定义连接网络属性
 */
@property(nonatomic, strong) NSURLConnection *connection;

@end

@implementation LoadFile
/**
 *  下载
 *
 *  @param urlstring Url地址
 */
- (void)loadFileUrlString:(NSString *)urlstring;
{
  self.expectedLength = [self getServerFileSize:urlstring];

  NSURL *url = [NSURL URLWithString:urlstring];

  NSURLRequest *request = [NSURLRequest requestWithURL:url];

  //下载的操作应该在子线程执行,放在主线程会卡顿
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    // 其代理方法是由运行循环监听执行的,而子线程的运行默认不开启
    self.connection =
        [NSURLConnection connectionWithRequest:request delegate:self];
    // 开启当前线程的运行循环.这个运行循环会在下载完毕之后自动关闭
    [[NSRunLoop currentRunLoop] run];
  });

  //    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue
  //    mainQueue] completionHandler:^(NSURLResponse * _Nullable response,
  //    NSData * _Nullable data, NSError * _Nullable connectionError) {
  //
  //        if (connectionError != nil || data.length == 0) {
  //            NSLog(@"错误:%@",connectionError);
  //            return;
  //        }
  //        [data writeToFile:@"/Users/heima/Desktop/sougou.zip"
  //        atomically:true];
  //    }];
}
/**
 *  使用head请求方式,和url地址来获取服务器大小
 *
 *  @return 返回一个二进制数据
 */
- (long long)getServerFileSize:(NSString *)urlstring {

  NSURL *url = [NSURL URLWithString:urlstring];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

  request.HTTPMethod = @"HEAD";

  NSURLResponse *response;

  [NSURLConnection sendSynchronousRequest:request
                        returningResponse:&response
                                    error:NULL];

  return response.expectedContentLength;
}

/**
    第二种方式:
 *   保存每一次下载的数据
     利用文件句柄NSFileHandle
     要解决内存峰值过高,需要下载一点就保存一点
 */
- (void)saveData:(NSData *)data {

  NSString *location = @"/Users/xmy/Desktop/sougou.zip";

  //创建文件句柄
  NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:location];

  if (handle == nil) {
    [data writeToFile:location atomically:true];
  } else {
    //当handle有值,说明已经开始下载了,每次下载把文件句柄移到文件的最后
    //如果没有这句话,每次下载一点之后还是会从头开始下载
    [handle seekToEndOfFile];
    //如果该文件存在,将data数据存入文件
    [handle writeData:data];
    //写入完毕,需要关闭该文件的句柄
    [handle closeFile];
  }
}

#pragma mark - 代理方法

/**
 *  已经收到响应的时候就会调用这个方法
 */
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response;
{
  /**
   *  不通过这种方式获取文件大小了,改使用head方式获取
   */
  // self.expectedLength = response.expectedContentLength;

  NSLog(@"收到响应%@   %lld", response, response.expectedContentLength);

  NSString *filePath = @"/Users/xmy/Desktop/sougou.zip";
  /**
   *  第三种方式:输出流
   先定义一个全局
   初始化输出流 并打开管道
   第一个参数 文件存入的路径
   第二个参数 是否往后面拼接路径
   */
  self.stream = [NSOutputStream outputStreamToFileAtPath:filePath append:true];
  //打开管道
  [self.stream open];
}
/**
 已经收到数据的时候才会调用这个方法
 *
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
  self.currentLength += data.length;
  //计算进度
  float proceress = (float)self.currentLength / self.expectedLength;
  NSLog(@"收到的数据 %f %lu", proceress, data.length);

  //将数据通过输出流管道写入文件
  //参数1:8位的二进制数据    参数二:写入的最大大小
  [self.stream write:data.bytes maxLength:data.length];

  //往可变的二进制文件里拼接数据
  // [self.dataM appendData:data];
  //将数据存入到需要下载的文件里
  // [self saveData:data];
}
/**
 这次连接结束的时候会调用这个方法
 *
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

  NSLog(@"下载完成");
  //关闭管道
  [self.stream close];

  //在下载响应完成时,将该二进制数据保存到指定的位置,公司开发的话会保存到沙盒,
  //[self.dataM writeToFile:@"/Users/xmy/Desktop/sougou.zip" atomically:true];
}
/**
 *  下载失败的方法
 */
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {

  NSLog(@"下载失败!%@", error);
  //关闭管道
  [self.stream close];
}

/**
 *  暂停下载
 */
- (void)pasueDownload;
{

  //断开连接,就会取消下载
  [self.connection cancel];

  [self.stream close];
}

#pragma mark - 懒加载

//-(NSMutableData *)dataM{
//
//    if(_dataM == nil){
//
//        _dataM = [NSMutableData data];
//
//    }
//    return _dataM;
//}
@end
