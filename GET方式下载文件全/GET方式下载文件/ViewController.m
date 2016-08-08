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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
//下载按钮
- (IBAction)downLoadClick:(id)sender {
    
    NSString *str = @"http://127.0.0.1/myWeb/sougou.zip";
    //调用分类方法下载文件
    [[LoadFile new] loadFileUrlString:str];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
