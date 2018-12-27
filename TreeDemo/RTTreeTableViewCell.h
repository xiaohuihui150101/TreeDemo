//
//  RTTreeTableViewCell.h
//  TreeDemo
//
//  Created by isoft on 2018/12/26.
//  Copyright © 2018 isoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTTreeItem;

NS_ASSUME_NONNULL_BEGIN

@interface RTTreeTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView andTreeItem:(RTTreeItem *)item;
- (void)updateItem;

@property (nonatomic, copy)   void (^checkButtonClickBlock)(RTTreeItem *item);
@property (nonatomic, assign) BOOL isShowArrow;
@property (nonatomic, assign) BOOL isShowCheck;
@property (nonatomic, assign) BOOL isShowLevelColor;

@property (nonatomic, strong) UILabel *nameLB;
@property (nonatomic, strong) UIImageView *arrowImg;

@end

NS_ASSUME_NONNULL_END
