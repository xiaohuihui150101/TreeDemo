//
//  RTTreeItem.h
//  TreeDemo
//
//  Created by isoft on 2018/12/26.
//  Copyright © 2018 isoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RTTreeItemCheckState){
    RTTreeItemDefault,      // 不选择（默认）
    RTTreeItemChecked,      // 全选
    RTTreeItemHalfChecked,  // 半选
};



@interface RTTreeItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSNumber *parentId;
@property (nonatomic, strong) NSNumber *orderNo;//序号
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL isLeaf;
@property (nonatomic, strong) id data;

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) RTTreeItemCheckState checkState;  // 勾选状态
@property (nonatomic, assign) BOOL isExpand;//是否为展开状态
@property (nonatomic, weak) RTTreeItem *parentItem;
@property (nonatomic, strong) NSMutableArray<RTTreeItem *> *childItems;

//初始化
- (instancetype)initWithName:(NSString *)name id:(NSNumber *)id parentId:(NSNumber *)parentId orderNo:(NSNumber *)orderNo type:(NSString *)type isLeaf:(BOOL)isLeaf data:(id)data;

@end

