//
//  ViewController.m
//  GET方式下载文件
//
//  Created by xmy on 16/8/8.
//  Copyright © 2016年 xmy. All rights reserved.
//

#import "ViewController.h"
#import "LoadFile.h"

@interface ViewController ()

@property(nonatomic,strong)LoadFile *loadfile;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

//下载按钮
- (IBAction)downLoadClick:(id)sender {
    
    self.loadfile = [[LoadFile alloc] init];
    [self.loadfile loadFileUrlString:@"http://127.0.0.1/myWeb/sougou.zip"progress:^(float progress) {
        
        self.progressView.progress = progress;
        
    }finish:^(BOOL isSuccess, NSError *error) {
        if(isSuccess)
        {
            NSLog(@"提示下载成功");
        }else{
            NSLog(@"下载失败%@",error);
        }
    }];
    
}

//暂停按钮
- (IBAction)pasue:(id)sender {

    //暂停下载
   [self.loadfile pasueDownload];
    NSLog(@"-----------------------------------------------------------");

}

//测试循环引用
- (void)dealloc{
    NSLog(@"( ^_^ )/~~拜拜");
}

@end
