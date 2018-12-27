//
//  RTTreeItem.m
//  TreeDemo
//
//  Created by isoft on 2018/12/26.
//  Copyright © 2018 isoft. All rights reserved.
//

#import "RTTreeItem.h"

@implementation RTTreeItem

- (instancetype)initWithName:(NSString *)name id:(NSNumber *)id parentId:(NSNumber *)parentId orderNo:(NSNumber *)orderNo type:(NSString *)type isLeaf:(BOOL)isLeaf data:(id)data {
    self = [super init];
    if (self) {
        
        _name = name;
        _id = id;
        _parentId = parentId;
        _orderNo = orderNo;
        _type = type;
        _isLeaf = isLeaf;
        _data = data;
        _level = 0;
        _isExpand = NO;
        _checkState = RTTreeItemDefault;
        _childItems = [NSMutableArray array];
        
    }
    return self;
}

@end
