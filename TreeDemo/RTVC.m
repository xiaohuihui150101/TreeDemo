//
//  RTVC.m
//  TreeDemo
//
//  Created by isoft on 2018/12/26.
//  Copyright © 2018 isoft. All rights reserved.
//

#import "RTVC.h"

@interface RTVC ()<RTTreeTableViewControllerParentClassDelegate>

@end

@implementation RTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.classDelegate = self;
    
}
#pragma mark -- RTTreeTableViewControllerParentClassDelegate
/** 获取数据，创建模型，创建 manager */
- (RTTreeTableManager *)managerInTableViewController:(RTTreeTableViewController *)tableViewController {
    // 获取数据并创建树形结构
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"City_Resource" ofType:@"json"]];
    NSArray *provinceArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    
    NSMutableArray *items = [NSMutableArray array];
    
    // 1. 遍历省份
    [provinceArray enumerateObjectsUsingBlock:^(NSDictionary *province, NSUInteger idx, BOOL * _Nonnull stop) {
        
        RTTreeItem *provinceItem = [[RTTreeItem alloc] initWithName:province[@"name"]
                                                                 id:@([province[@"code"] integerValue])
                                                           parentId:nil
                                                            orderNo:@(idx)
                                                               type:@"province"
                                                             isLeaf:NO
                                                               data:province];
        [items addObject:provinceItem];
        
        // 2. 遍历城市
        NSArray *cityArray = province[@"children"];
        [cityArray enumerateObjectsUsingBlock:^(NSDictionary *city, NSUInteger idx, BOOL * _Nonnull stop) {
            
            RTTreeItem *cityItem = [[RTTreeItem alloc] initWithName:city[@"name"]
                                                                 id:@([city[@"code"] integerValue])
                                                           parentId:provinceItem.id
                                                            orderNo:@(idx)
                                                               type:@"city"
                                                             isLeaf:NO
                                                               data:city];
            [items addObject:cityItem];
            
            // 3. 遍历区
            NSArray *districtArray = city[@"children"];
            [districtArray enumerateObjectsUsingBlock:^(NSDictionary *district, NSUInteger idx, BOOL * _Nonnull stop) {
                
                RTTreeItem *districtItem = [[RTTreeItem alloc] initWithName:district[@"name"]
                                                                         id:@([district[@"code"] integerValue])
                                                                   parentId:cityItem.id
                                                                    orderNo:@(idx)
                                                                       type:@"district"
                                                                     isLeaf:YES
                                                                       data:district];
                [items addObject:districtItem];
            }];
        }];
    }];
    
    // ExpandLevel 为 0 全部折叠，为 1 展开一级，以此类推，为 NSIntegerMax 全部展开
    RTTreeTableManager *manager = [[RTTreeTableManager alloc] initWithItems:items andExpandLevel:1];
    
    return manager;
}

- (void)tableViewController:(RTTreeTableViewController *)tableViewController checkItems:(NSArray<RTTreeItem *> *)items {
    
    // 这里加一个隔离带目的是可以在这里做出个性化操作，然后再将数据传出
    if ([self.delegate respondsToSelector:@selector(tableViewController:checkItems:)]) {
        [self.delegate tableViewController:self checkItems:items];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)tableViewController:(RTTreeTableViewController *)tableViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"点击了第 %ld 行", (long)indexPath.row);
}

- (void)tableViewController:(RTTreeTableViewController *)tableViewController didSelectCheckBoxRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"点击了第 %ld 行的 checkbox", (long)indexPath.row);
}



@end
