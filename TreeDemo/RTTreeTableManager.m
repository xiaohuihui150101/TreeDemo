//
//  RTTreeTableManager.m
//  TreeDemo
//
//  Created by isoft on 2018/12/26.
//  Copyright © 2018 isoft. All rights reserved.
//

#import "RTTreeTableManager.h"

@interface RTTreeTableManager ()

@property (nonatomic, strong) NSDictionary *itemsMap;
@property (nonatomic, strong) NSMutableArray <RTTreeItem *>*topItems;
@property (nonatomic, strong) NSMutableArray <RTTreeItem *>*tmpItems;
@property (nonatomic, assign) NSInteger maxLevel;   // 获取最大等级
@property (nonatomic, assign) NSInteger showLevel;  // 设置最大的等级

@end

@implementation RTTreeTableManager


#pragma mark - Init

- (instancetype)initWithItems:(NSArray<RTTreeItem *> *)items andExpandLevel:(NSInteger)level
{
    self = [super init];
    if (self) {
        
        // 1. 建立 map
        [self setupItemsMapWithItems:items];
        
        // 2. 建立父子关系，并得到顶级节点
        [self setupTopItemsWithFilterField:nil];
        
        // 3. 设置等级
        [self setupItemsLevel];
        
        // 4. 根据展开等级设置 showItems
        [self setupShowItemsWithShowLevel:level];
    }
    return self;
}

// 建立 map
- (void)setupItemsMapWithItems:(NSArray *)items {
    
    NSMutableDictionary *itemsMap = [NSMutableDictionary dictionary];
    for (RTTreeItem *item in items) {
        [itemsMap setObject:item forKey:item.id];
    }
    self.itemsMap = itemsMap;
}

// 建立父子关系，并得到顶级节点
- (void)setupTopItemsWithFilterField:(NSString *)field {
    
    self.tmpItems = self.itemsMap.allValues.mutableCopy;
    
    // 建立父子关系
    NSMutableArray *topItems = [NSMutableArray array];
    for (RTTreeItem *item in self.tmpItems) {
        
        item.isExpand = NO;
        
        if ([item.parentId isKindOfClass:[NSNumber class]]) {
            RTTreeItem *parent = self.itemsMap[item.parentId];
            if (parent) {
                item.parentItem = parent;
                if (![parent.childItems containsObject:item]) {
                    [parent.childItems addObject:item];
                }
            }
        }
        if (!item.parentItem) {
            [topItems addObject:item];
        }
    }
    
    // 所有 item 排序
    for (RTTreeItem *item in self.tmpItems) {
        item.childItems = [item.childItems sortedArrayUsingComparator:^NSComparisonResult(RTTreeItem *obj1, RTTreeItem *obj2) {
            return [obj1.orderNo compare:obj2.orderNo];
        }].mutableCopy;
    }
    
    // 顶级节点排序
    topItems = [topItems sortedArrayUsingComparator:^NSComparisonResult(RTTreeItem *obj1, RTTreeItem *obj2) {
        return [obj1.orderNo compare:obj2.orderNo];
    }].mutableCopy;
    
    self.topItems = topItems;
}

// 设置等级
- (void)setupItemsLevel {
    
    for (RTTreeItem *item in self.tmpItems) {
        int tmpLevel = 0;
        RTTreeItem *p = item.parentItem;
        while (p) {
            tmpLevel++;
            p = p.parentItem;
        }
        item.level = tmpLevel;
        
        // 设置最大等级
        _maxLevel = MAX(_maxLevel, tmpLevel);
    }
}

// 根据展开等级设置 showItems
- (void)setupShowItemsWithShowLevel:(NSInteger)level {
    
    _showLevel = MAX(level, 0);
    _showLevel = MIN(level, _maxLevel);
    
    NSMutableArray *showItems = [NSMutableArray array];
    for (RTTreeItem *item in self.topItems) {
        [self addItem:item toShowItems:showItems andAllowShowLevel:_showLevel];
    }
    _showItems = showItems;
}


- (void)addItem:(RTTreeItem *)item toShowItems:(NSMutableArray *)showItems andAllowShowLevel:(NSInteger)level {
    
    [showItems addObject:item];
    
    if (item.level <= level) {
        
        item.isExpand = YES;
        item.childItems = [item.childItems sortedArrayUsingComparator:^NSComparisonResult(RTTreeItem *obj1, RTTreeItem *obj2) {
            return [obj1.orderNo compare:obj2.orderNo];
        }].mutableCopy;
        
        for (RTTreeItem *childItem in item.childItems) {
            [self addItem:childItem toShowItems:showItems andAllowShowLevel:level];
        }
    }
}


#pragma mark - Expand Item

// 展开/收起 Item，返回所改变的 Item 的个数
- (NSInteger)expandItem:(RTTreeItem *)item {
    return [self expandItem:item isExpand:!item.isExpand];
}

- (NSInteger)expandItem:(RTTreeItem *)item isExpand:(BOOL)isExpand {
    
    if (item.isExpand == isExpand) return 0;
    item.isExpand = isExpand;
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    // 如果展开
    if (isExpand) {
        for (RTTreeItem *tmpItem in item.childItems) {
            [self addItem:tmpItem toTmpItems:tmpArray];
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.showItems indexOfObject:item] + 1, tmpArray.count)];
        [self.showItems insertObjects:tmpArray atIndexes:indexSet];
    }
    // 如果折叠
    else {
        for (RTTreeItem *tmpItem in self.showItems) {
            
            BOOL isParent = NO;
            
            RTTreeItem *parentItem = tmpItem.parentItem;
            while (parentItem) {
                if (parentItem == item) {
                    isParent = YES;
                    break;
                }
                parentItem = parentItem.parentItem;
            }
            if (isParent) {
                [tmpArray addObject:tmpItem];
            }
        }
        [self.showItems removeObjectsInArray:tmpArray];
    }
    
    return tmpArray.count;
}
- (void)addItem:(RTTreeItem *)item toTmpItems:(NSMutableArray *)tmpItems {
    
    [tmpItems addObject:item];
    
    if (item.isExpand) {
        
        item.childItems = [item.childItems sortedArrayUsingComparator:^NSComparisonResult(RTTreeItem *obj1, RTTreeItem *obj2) {
            return [obj1.orderNo compare:obj2.orderNo];
        }].mutableCopy;
        
        for (RTTreeItem *tmpItem in item.childItems) {
            [self addItem:tmpItem toTmpItems:tmpItems];
        }
    }
}

// 展开/折叠到多少层级
- (void)expandItemWithLevel:(NSInteger)expandLevel completed:(void (^)(NSArray *))noExpandCompleted andCompleted:(void (^)(NSArray *))expandCompleted {
    
    expandLevel = MAX(expandLevel, 0);
    expandLevel = MIN(expandLevel, self.maxLevel);
    
    // 先一级一级折叠
    for (NSInteger level = self.maxLevel; level >= expandLevel; level--) {
        
        NSMutableArray *itemArray = [NSMutableArray array];
        for (NSInteger i = 0; i < self.showItems.count; i++) {
            
            RTTreeItem *item = self.showItems[i];
            if (item.isExpand && item.level == level) {
                [itemArray addObject:item];
            }
        }
        
        if (noExpandCompleted) {
            noExpandCompleted(itemArray);
        }
    }
    
    // 再一级一级展开
    for (NSInteger level = 0; level <= expandLevel; level++) {
        
        NSMutableArray *itemArray = [NSMutableArray array];
        for (NSInteger i = 0; i < self.showItems.count; i++) {
            
            RTTreeItem *item = self.showItems[i];
            if (!item.isExpand && item.level == level) {
                [itemArray addObject:item];
            }
        }
        
        if (expandCompleted) {
            expandCompleted(itemArray);
        }
    }
}


#pragma mark - Check Item

// 勾选/取消勾选 Item
- (void)checkItem:(RTTreeItem *)item {
    [self checkItem:item isCheck:!(item.checkState == RTTreeItemChecked)];
}

- (void)checkItem:(RTTreeItem *)item isCheck:(BOOL)isCheck {
    
    if (item.checkState == RTTreeItemChecked && isCheck) return;
    if (item.checkState == RTTreeItemDefault && !isCheck) return;
    
    // 勾选/取消勾选所有子 item
    [self checkChildItemWithItem:item isCheck:isCheck];
    // 刷新父 item 勾选状态
    [self refreshParentItemWithItem:item];
}
// 递归，勾选/取消勾选子 item
- (void)checkChildItemWithItem:(RTTreeItem *)item isCheck:(BOOL)isCheck {
    
    item.checkState = isCheck ? RTTreeItemChecked : RTTreeItemDefault;
    
    for (RTTreeItem *tmpItem in item.childItems) {
        [self checkChildItemWithItem:tmpItem isCheck:isCheck];
    }
}
// 递归，刷新父 item 勾选状态
- (void)refreshParentItemWithItem:(RTTreeItem *)item {
    
    NSInteger defaultNum = 0;
    NSInteger checkedNum = 0;
    
    for (RTTreeItem *tmpItem in item.parentItem.childItems) {
        
        switch (tmpItem.checkState) {
            case RTTreeItemDefault:
                defaultNum++;
                break;
            case RTTreeItemChecked:
                checkedNum++;
                break;
            case RTTreeItemHalfChecked:
                break;
        }
    }
    
    if (defaultNum == item.parentItem.childItems.count) {
        item.parentItem.checkState = RTTreeItemDefault;
    }
    else if (checkedNum == item.parentItem.childItems.count) {
        item.parentItem.checkState = RTTreeItemChecked;
    }
    else {
        item.parentItem.checkState = RTTreeItemHalfChecked;
    }
    
    if (item.parentItem) {
        [self refreshParentItemWithItem:item.parentItem];
    }
}

// 全部勾选/全部取消勾选
- (void)checkAllItem:(BOOL)isCheck {
    
    for (RTTreeItem *item in _showItems) {
        // 防止重复遍历
        if (item.level == 0) {
            [self checkChildItemWithItem:item isCheck:isCheck];
        }
    }
}

// 获取所有已经勾选的 Item
- (NSArray <RTTreeItem *>*)getAllCheckItem {
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (RTTreeItem *item in _showItems) {
        // 防止重复遍历
        if (item.level == 0) {
            [self getAllCheckItem:tmpArray andItem:item];
        }
    }
    
    return tmpArray.copy;
}
// 递归，将已经勾选的 Item 添加到临时数组中
- (void)getAllCheckItem:(NSMutableArray <RTTreeItem *>*)tmpArray andItem:(RTTreeItem *)tmpItem {
    
    if (tmpItem.checkState == RTTreeItemDefault) return;
    if (tmpItem.checkState == RTTreeItemChecked) [tmpArray addObject:tmpItem];
    
    for (RTTreeItem *item in tmpItem.childItems) {
        [self getAllCheckItem:tmpArray andItem:item];
    }
}


#pragma mark - Filter Item

// 筛选
- (void)filterField:(NSString *)field {
    
    [self setupTopItemsWithFilterField:field];
    
    // 筛选
    if (field.length) {
        
        for (RTTreeItem *item in self.tmpItems) {
            
            NSArray *childItems  = [self getAllChildItemsWithItem:item];
            if ([self isContainField:field andItems:childItems]) {
                item.isExpand = YES;
                continue;
            }
            
            if ([self isContainField:field andItems:@[item]]) {
                continue;
            }
            
            NSArray *parentItems = [self getAllParentItemsWithItem:item];
            if ([self isContainField:field andItems:parentItems]) {
                continue;
            }
            
            // 如果都不存在
            [item.parentItem.childItems removeObject:item];
            
            if ([self.topItems containsObject:item]) {
                [self.topItems removeObject:item];
            }
            
            for (RTTreeItem *item in childItems) {
                [item.parentItem.childItems removeObject:item];
            }
        }
    }
    
    // 设置 showItems
    if (field.length) {
        NSMutableArray *showItems = [NSMutableArray array];
        for (RTTreeItem *item in self.topItems) {
            [self addItem:item toShowItems:showItems];
        }
        _showItems = showItems;
    }
    else {
        [self setupShowItemsWithShowLevel:_showLevel];
    }
    
    // 刷新勾选状态
    for (RTTreeItem *item in self.tmpItems) {
        // 刷新父 item 勾选状态
        [self refreshParentItemWithItem:item];
    }
}
- (void)addItem:(RTTreeItem *)item toShowItems:(NSMutableArray *)showItems {
    
    [showItems addObject:item];
    
    if (item.childItems.count) {
        
        item.childItems = [item.childItems sortedArrayUsingComparator:^NSComparisonResult(RTTreeItem *obj1, RTTreeItem *obj2) {
            return [obj1.orderNo compare:obj2.orderNo];
        }].mutableCopy;
        
        for (RTTreeItem *childItem in item.childItems) {
            if (item.isExpand) {
                [self addItem:childItem toShowItems:showItems];
            }
        }
    }
}


#pragma mark - Other

// 根据 id 获取 item
- (RTTreeItem *)getItemWithItemId:(NSNumber *)itemId {
    
    if (!itemId) return nil;
    
    return self.itemsMap[itemId];
}

// 获取该 item 下面所有子 item
- (NSArray *)getAllChildItemsWithItem:(RTTreeItem *)item {
    
    NSMutableArray *childItems = [NSMutableArray array];
    
    [self addItem:item toChildItems:childItems];
    
    return childItems;
}
// 递归，获取该 item 下面所有子 item
- (void)addItem:(RTTreeItem *)item toChildItems:(NSMutableArray *)childItems {
    
    for (RTTreeItem *childItem in item.childItems) {
        
        [childItems addObject:childItem];
        [self addItem:childItem toChildItems:childItems];
    }
}

// 获取该 item 的所有父 item
- (NSArray *)getAllParentItemsWithItem:(RTTreeItem *)item {
    
    NSMutableArray *parentItems = [NSMutableArray array];
    
    RTTreeItem *parentItem = item.parentItem;
    while (parentItem) {
        [parentItems addObject:parentItem];
        parentItem = parentItem.parentItem;
    }
    
    return parentItems;
}

// item 数组中是否包含该字段
- (BOOL)isContainField:(NSString *)field andItems:(NSArray *)items {
    
    BOOL isContain = NO;
    for (RTTreeItem *item in items) {
        if ([item.name containsString:field]) {
            isContain = YES;
            break;
        }
    }
    return isContain;
}

@end
