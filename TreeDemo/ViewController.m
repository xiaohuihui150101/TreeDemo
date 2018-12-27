//
//  ViewController.m
//  TreeDemo
//
//  Created by isoft on 2018/12/26.
//  Copyright © 2018 isoft. All rights reserved.
//

#import "ViewController.h"
#import "RTVC.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(100, 100, 100, 30);
    [btn addTarget:self action:@selector(btnWithAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
}

- (void)btnWithAction:(UIButton *)sender {
    NSLog(@"点击按钮");
    RTVC *vc = [[RTVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
