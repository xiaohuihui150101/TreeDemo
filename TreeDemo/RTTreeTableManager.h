//
//  RTTreeTableManager.h
//  TreeDemo
//
//  Created by isoft on 2018/12/26.
//  Copyright © 2018 isoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTTreeItem.h"


NS_ASSUME_NONNULL_BEGIN

@interface RTTreeTableManager : NSObject

/** 获取可见的节点 */
@property (nonatomic, readonly, strong) NSMutableArray<RTTreeItem *> *showItems;

/** 初始化，ExpandLevel 为 0 全部折叠，为 1 展开一级，以此类推，为 NSIntegerMax 全部展开 */
- (instancetype)initWithItems:(NSArray<RTTreeItem *> *)items andExpandLevel:(NSInteger)level;

/** 展开/收起 Item，返回所改变的 Item 的个数 */
- (NSInteger)expandItem:(RTTreeItem *)item;
- (NSInteger)expandItem:(RTTreeItem *)item isExpand:(BOOL)isExpand;
/** 展开/折叠到多少层级 */
- (void)expandItemWithLevel:(NSInteger)expandLevel completed:(void(^)(NSArray *noExpandArray))noExpandCompleted andCompleted:(void(^)(NSArray *expandArray))expandCompleted;

/** 勾选/取消勾选 Item */
- (void)checkItem:(RTTreeItem *)item;
- (void)checkItem:(RTTreeItem *)item isCheck:(BOOL)isCheck;
/** 全部勾选/全部取消勾选 */
- (void)checkAllItem:(BOOL)isCheck;
/** 获取所有已经勾选的 Item */
- (NSArray <RTTreeItem *>*)getAllCheckItem;

/** 筛选 */
- (void)filterField:(NSString *)field;

/** 根据 id 获取 item */
- (RTTreeItem *)getItemWithItemId:(NSNumber *)itemId;


@end

NS_ASSUME_NONNULL_END
