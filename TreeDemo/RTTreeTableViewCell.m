//
//  RTTreeTableViewCell.m
//  TreeDemo
//
//  Created by isoft on 2018/12/26.
//  Copyright © 2018 isoft. All rights reserved.
//

#import "RTTreeTableViewCell.h"
#import "RTTreeItem.h"

@interface RTTreeTableViewCell ()

@property (nonatomic, strong) RTTreeItem *treeItem;
@property (nonatomic, strong) UIButton *checkButton;

@end

@implementation RTTreeTableViewCell


#pragma mark - Init

+ (instancetype)cellWithTableView:(UITableView *)tableView andTreeItem:(RTTreeItem *)item {
    
    static NSString *ID = @"RTTreeTableViewCell";
    RTTreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[RTTreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.treeItem = item;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.indentationWidth = 15;
        self.selectionStyle   = UITableViewCellSelectionStyleNone;
        
        [self nameLB];
        [self arrowImg];
        
    }
    return self;
}


#pragma mark - Setter

- (void)setTreeItem:(RTTreeItem *)treeItem {
    _treeItem = treeItem;
    
    self.indentationLevel = treeItem.level;
    self.nameLB.text = treeItem.name;
    self.arrowImg.image  = treeItem.isLeaf ? nil : [UIImage imageNamed:@"MYTreeTableView.bundle/arrow"];
    self.accessoryView    = self.checkButton;
    
    [self refreshArrow];
    [self.checkButton setImage:[self getCheckImage] forState:UIControlStateNormal];
}

- (void)setIsShowArrow:(BOOL)isShowArrow {
    _isShowArrow = isShowArrow;
    
    if (!isShowArrow && self.arrowImg.image) {
        self.arrowImg.image = nil;
    }
}

- (void)setIsShowCheck:(BOOL)isShowCheck {
    _isShowCheck = isShowCheck;
    
    if (!isShowCheck && self.accessoryView) {
        self.accessoryView = nil;
    }
}


#pragma mark - Public Method

- (void)updateItem {
    // 刷新 title 前面的箭头方向
    [UIView animateWithDuration:0.25 animations:^{
        [self refreshArrow];
    }];
}


#pragma mark - Lazy Load

- (UIButton *)checkButton {
    if (!_checkButton) {
        
        UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkButton addTarget:self action:@selector(checkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [checkButton setImage:[self getCheckImage] forState:UIControlStateNormal];
        checkButton.adjustsImageWhenHighlighted = NO;
        checkButton.frame = CGRectMake(0, 0, self.contentView.bounds.size.height, self.contentView.bounds.size.height);
        CGFloat aEdgeInset = (checkButton.frame.size.height - checkButton.imageView.image.size.height) / 2;
        checkButton.contentEdgeInsets = UIEdgeInsetsMake(aEdgeInset, aEdgeInset, aEdgeInset, aEdgeInset);
        
        _checkButton = checkButton;
    }
    return _checkButton;
}

- (UILabel *)nameLB {
    if (!_nameLB) {
        _nameLB = [[UILabel alloc] init];
        _nameLB.textColor = [UIColor blackColor];
        _nameLB.font = [UIFont systemFontOfSize:14];
        _nameLB.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLB];
        [_nameLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.height.equalTo(@(24));
        }];
    }
    return _nameLB;
}

- (UIImageView *)arrowImg {
    if (!_arrowImg) {
        _arrowImg = [[UIImageView alloc] init];
        [self.contentView addSubview:_arrowImg];
        [_arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLB.mas_centerY);
            make.left.equalTo(self.nameLB.mas_right).offset(5);
            make.width.equalTo(@(10));
            make.height.equalTo(@(16));
        }];
    }
    return _arrowImg;
}


#pragma mark - Private Method

- (void)refreshArrow {
    
    if (self.treeItem.isExpand) {
        self.arrowImg.transform = CGAffineTransformMakeRotation(M_PI_2);
    } else {
        self.arrowImg.transform = CGAffineTransformMakeRotation(0);
    }
}

- (void)checkButtonClick:(UIButton *)sender {
    if (self.checkButtonClickBlock) {
        self.checkButtonClickBlock(self.treeItem);
    }
}

- (UIImage *)getCheckImage {
    
    switch (self.treeItem.checkState) {
        case RTTreeItemDefault:
            return [UIImage imageNamed:@"MYTreeTableView.bundle/checkbox-uncheck"];
            break;
        case RTTreeItemChecked:
            return [UIImage imageNamed:@"MYTreeTableView.bundle/checkbox-checked"];
            break;
        case RTTreeItemHalfChecked:
            return [UIImage imageNamed:@"MYTreeTableView.bundle/checkbox-partial"];
            break;
        default:
            return nil;
            break;
    }
}


@end
