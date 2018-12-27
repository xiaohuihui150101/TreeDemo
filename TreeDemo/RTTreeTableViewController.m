//
//  RTTreeTableViewController.m
//  TreeDemo
//
//  Created by isoft on 2018/12/26.
//  Copyright © 2018 isoft. All rights reserved.
//

#import "RTTreeTableViewController.h"
#import "RTTreeTableViewCell.h"

@interface RTTreeTableViewController ()

@property (nonatomic, strong) RTTreeTableManager *manager;
@property (nonatomic, strong) UIRefreshControl   *myRefreshControl;

@end

@implementation RTTreeTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self initialization];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myRefreshControl = [[UIRefreshControl alloc] init];
    self.myRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [self.myRefreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.myRefreshControl];
    
    //    self.tableView.tableHeaderView = self.isShowSearchBar ? [self getSearchBar] : nil;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)refreshData {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if ([self.classDelegate respondsToSelector:@selector(managerInTableViewController:)]) {
            
            self.manager = [self.classDelegate managerInTableViewController:self];
            
            // 遍历外部传来的所选择的 itemId
            for (NSNumber *itemId in self.checkItemIds) {
                RTTreeItem *item = [self.manager getItemWithItemId:itemId];
                if (item) {
                    [self.manager checkItem:item isCheck:YES];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.myRefreshControl endRefreshing];
        });
    });
}


#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.manager.showItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RTTreeItem *item = self.manager.showItems[indexPath.row];
    
    RTTreeTableViewCell *cell = [RTTreeTableViewCell cellWithTableView:tableView andTreeItem:item];
    cell.isShowArrow      = self.isShowArrow;
    cell.isShowCheck      = self.isShowCheck;
    cell.isShowLevelColor = self.isShowLevelColor;
    
    if ((item.level < self.levelColorArray.count) && self.isShowLevelColor) {
        cell.backgroundColor = self.levelColorArray[item.level];
    } else {
        cell.backgroundColor = self.normalBackgroundColor;
    }
    
    __weak typeof(self)wself = self;
    cell.checkButtonClickBlock = ^(RTTreeItem *item) {
        
        [wself.manager checkItem:item];
        [wself.tableView reloadData];
        
        // 如果是单选，除了勾选之外，还需把勾选的 item 传出去
        if (wself.isSingleCheck) {
            if ([wself.classDelegate respondsToSelector:@selector(tableViewController:checkItems:)]) {
                [wself.classDelegate tableViewController:wself checkItems:@[item]];
            }
        }
        
        if ([wself.classDelegate respondsToSelector:@selector(tableViewController:didSelectCheckBoxRowAtIndexPath:)]) {
            [wself.classDelegate tableViewController:wself didSelectCheckBoxRowAtIndexPath:indexPath];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RTTreeItem *item = self.manager.showItems[indexPath.row];
    
    [self tableView:tableView didSelectItems:@[item] isExpand:!item.isExpand];
    
    if ([self.classDelegate respondsToSelector:@selector(tableViewController:didSelectRowAtIndexPath:)]) {
        [self.classDelegate tableViewController:self didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - Private Method

- (NSArray <NSIndexPath *>*)getUpdateIndexPathsWithCurrentIndexPath:(NSIndexPath *)indexPath andUpdateNum:(NSInteger)updateNum {
    
    NSMutableArray *tmpIndexPaths = [NSMutableArray arrayWithCapacity:updateNum];
    for (int i = 0; i < updateNum; i++) {
        NSIndexPath *tmp = [NSIndexPath indexPathForRow:(indexPath.row + 1 + i) inSection:indexPath.section];
        [tmpIndexPaths addObject:tmp];
    }
    return tmpIndexPaths;
}

- (UIColor *)getColorWithRed:(NSInteger)redNum green:(NSInteger)greenNum blue:(NSInteger)blueNum {
    return [UIColor colorWithRed:redNum/255.0 green:greenNum/255.0 blue:blueNum/255.0 alpha:1.0];
}


- (void)tableView:(UITableView *)tableView didSelectItems:(NSArray <RTTreeItem *>*)items isExpand:(BOOL)isExpand {
    
    NSMutableArray *updateIndexPaths = [NSMutableArray array];
    NSMutableArray *editIndexPaths   = [NSMutableArray array];
    
    for (RTTreeItem *item in items) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.manager.showItems indexOfObject:item] inSection:0];
        [updateIndexPaths addObject:indexPath];
        
        NSInteger updateNum = [self.manager expandItem:item];
        NSArray *tmp = [self getUpdateIndexPathsWithCurrentIndexPath:indexPath andUpdateNum:updateNum];
        [editIndexPaths addObjectsFromArray:tmp];
    }
    
    if (isExpand) {
        [tableView insertRowsAtIndexPaths:editIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [tableView deleteRowsAtIndexPaths:editIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    for (NSIndexPath *indexPath in updateIndexPaths) {
        RTTreeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell updateItem];
    }
}

- (void)initialization {
    
    self.isSingleCheck    = NO;
    self.isShowArrow      = YES;
    self.isShowCheck      = YES;
    self.isShowLevelColor = NO;
    self.isShowSearchBar  = YES;
    self.isRealTimeSearch = YES;
    
    self.normalBackgroundColor = [UIColor whiteColor];
    self.levelColorArray = @[[self getColorWithRed:230 green:230 blue:230],
                             [self getColorWithRed:238 green:238 blue:238]];
}


#pragma mark - Public Method

// 全部勾选/全部取消勾选
- (void)checkAllItem:(BOOL)isCheck {
    [self.manager checkAllItem:isCheck];
    [self.tableView reloadData];
}

// 全部展开/全部折叠
- (void)expandAllItem:(BOOL)isExpand {
    [self expandItemWithLevel:(isExpand ? NSIntegerMax : 0)];
}

// 展开/折叠到多少层级
- (void)expandItemWithLevel:(NSInteger)expandLevel {
    
    __weak typeof(self)wself = self;
    
    [self.manager expandItemWithLevel:expandLevel completed:^(NSArray *noExpandArray) {
        
        [wself tableView:wself.tableView didSelectItems:noExpandArray isExpand:NO];
        
    } andCompleted:^(NSArray *expandArray) {
        
        [wself tableView:wself.tableView didSelectItems:expandArray isExpand:YES];
        
    }];
}

- (void)prepareCommit {
    
    // 所勾选的 items
    NSArray *checkItems = [self.manager getAllCheckItem];
    
    if ([self.classDelegate respondsToSelector:@selector(tableViewController:checkItems:)]) {
        [self.classDelegate tableViewController:self checkItems:checkItems];
    }
}

- (NSArray *)getShowItems {
    
    return self.manager.showItems;
}


@end
