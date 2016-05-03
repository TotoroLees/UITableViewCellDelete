//
//  DeleteViewCell.m
//  UITableViewCellDelete
//
//  Created by Lee on 16/4/26.
//  Copyright © 2016年 Totoro.Lee. All rights reserved.
//

#import "DeleteViewCell.h"

@implementation DeleteViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        if (super.editing == YES) {
            UIImageView *imageView = [[[self.subviews lastObject]subviews]firstObject];
            imageView.image = [UIImage imageNamed:@"chose_06"];
        }
    }
}

@end
