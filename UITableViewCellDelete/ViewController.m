//
//  ViewController.m
//  UITableViewCellDelete
//
//  Created by Lee on 16/4/26.
//  Copyright © 2016年 Totoro.Lee. All rights reserved.
//

#import "ViewController.h"
#import "EditView.h"
#import "DeleteViewCell.h"
#import "ReactiveCocoa.h"

// 宽
#define kScreenW [UIScreen mainScreen].bounds.size.width
// 高
#define kScreenH [UIScreen mainScreen].bounds.size.height

#define GrayColor [UIColor colorWithRed:(242)/255.0 green:(242)/255.0 blue:(242)/255.0 alpha:1.0]

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *deleteTableView;

@property (nonatomic, strong) EditView *editView;

//原数据数组
@property (nonatomic, strong) NSMutableArray *dataArray;

//删除数据数组
@property (nonatomic, strong) NSMutableArray *deleteDataArray;

//删除数据中数组的个数
@property (assign, nonatomic) NSUInteger number;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deleteTableView.delegate = self;
    self.deleteTableView.dataSource = self;
    
    /**
     *  编辑按钮的设置
     */
    UIButton *editingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [editingBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editingBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    editingBtn.frame = CGRectMake(kScreenW - 50 , 10, 40, 30);
    [editingBtn addTarget:self action:@selector(editingCilck:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithCustomView:editingBtn];
    self.navigationItem.rightBarButtonItem=rightBarButton;
    
    /**
     *  NSMutableArray的个数无法监听,才使用number.没有找到好的办法
     *  只要number的值发生变化,就会执行该方法
     *
     */
    [RACObserve(self, number) subscribeNext:^(id x) {
        if (self.number == 0) {
            [self.editView.deleteButton setBackgroundColor:[UIColor grayColor]];
            self.editView.smallButton.selected = NO;
            self.editView.bigButton.selected = NO;
            [self.editView.smallButton setBackgroundImage:[UIImage imageNamed:@"chose_03"] forState:0];
        }else if (self.number == self.dataArray.count) {
            [self.editView.deleteButton setBackgroundColor:[UIColor redColor]];
            self.editView.smallButton.selected = YES;
            self.editView.bigButton.selected = YES;
            [self.editView.smallButton setBackgroundImage:[UIImage imageNamed:@"chose_06"] forState:0];
        }else{
            [self.editView.deleteButton setBackgroundColor:[UIColor redColor]];
            self.editView.smallButton.selected = NO;
            self.editView.bigButton.selected = NO;
            [self.editView.smallButton setBackgroundImage:[UIImage imageNamed:@"chose_03"] forState:0];
        }
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /**
     *  此处要使用带 forIndexPath: 的这个方法.否则自定义选中视图,在Cell的复用中会变回系统自带的按钮图片.
     */
    DeleteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteViewCell" forIndexPath:indexPath];

    cell.deleteLable.text = self.dataArray[indexPath.row];
    
    /**
     *  此处一定不能使用 UITableViewCellSelectionStyleNone, 会造成选中之后再次点击无法改变选中视图的样式(会有很多问题,可以试试哈)
     */
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    /**
     *  复用过程中,自定义的选中按钮不会被系统还原,需配合上述 forIndexPath: 方法(需在 Cell选中状态 和 TableView编辑状态下)
     */
    if (cell.selected == YES && tableView.editing == YES) {
        /**
         *  取出系统自带的选中视图(在TableView允许编辑状态下打印 cell.subviews, 其中UITableViewCellEditControl 即为编辑状态下的视图
            [[cell.subviews lastObject]subviews]  选中状态下的视图)
         */
        UIImageView *imageView = [[[cell.subviews lastObject]subviews]firstObject];
        /**
         *  改变选中状态下的视图
         */
        imageView.image = [UIImage imageNamed:@"chose_06"];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

/**
 *  选中Cell的时候调用
 *
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [self.deleteTableView cellForRowAtIndexPath:indexPath];
    
    if (tableView.editing == YES) {
        UIImageView *imageView = [[[cell.subviews lastObject]subviews]firstObject];
        imageView.image = [UIImage imageNamed:@"chose_06"];
        
        /**
         *  将选中的数据添加到 deleteDataArray数组中
         */
        [self.deleteDataArray addObject:self.dataArray[indexPath.row]];
        self.number = self.deleteDataArray.count;
    }
}
/**
 *  取消选中时调用
 *
 */

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.editing == YES) {
        [self.deleteDataArray removeObject:self.dataArray[indexPath.row]];
        self.number = self.deleteDataArray.count;
    }
}

/**
 *  tableView 是否可以进入编辑状态
 *
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

/**
 *  设置编辑样式(如果不设置,会使用系统自带的删除方法,不能多选删除,只能单个删除. 会调用下面 注释掉的那个方法)
 *
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

/**
 *  系统自带的单个删除的方法
 *
 */
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.dataArray removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//    }
//}


/**
 *  编辑按钮
 *
 */
- (void)editingCilck:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setTitle:@"完成" forState:UIControlStateNormal];
        
        [self.view addSubview:self.editView];
        
        //启动表格的编辑模式
        self.deleteTableView.editing = YES;
    }else{
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
        
        [self.editView removeFromSuperview];
        
        //关闭表格的编辑模式
        self.deleteTableView.editing = NO;
    }
}

/**
 *  全选按钮
 */
- (void)editViewSelectButtonAction:(UIButton *)sender{
    if (sender.selected) {
        //先删除之前添加到 deleteDataArray 数组中的数据
        [self.deleteDataArray removeAllObjects];
        //再添加所有数据
        [self.deleteDataArray addObjectsFromArray:self.dataArray];
        
        for (int i = 0; i < self.dataArray.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            //设为选中状态
            [self.deleteTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            //改变选中状态下的视图
            UITableViewCell * cell = [self.deleteTableView cellForRowAtIndexPath:indexPath];
            UIImageView *imageView = [[[cell.subviews lastObject]subviews]firstObject];
            imageView.image = [UIImage imageNamed:@"chose_06"];
        }
        self.number = self.dataArray.count;
    }else{
        
        [self.deleteDataArray removeAllObjects];
        
        for (int i = 0; i < self.dataArray.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            //取消选中状态
            [self.deleteTableView deselectRowAtIndexPath:indexPath animated:YES];
            self.number = 0;
        }
    }
}

/**
 *  删除按钮
 */
- (void)editViewdeleteButtonAction:(UIButton *)sender{
    [self.dataArray removeObjectsInArray:self.deleteDataArray];
    [self.deleteTableView reloadData];
}



- (EditView *)editView{
    if (!_editView) {
        self.editView = [[EditView alloc] initWithFrame:CGRectMake(0, kScreenH - 50, kScreenW, 50)];
        _editView.backgroundColor = GrayColor;
        [_editView.deleteButton addTarget:self action:@selector(editViewdeleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_editView.bigButton addTarget:self action:@selector(editViewSelectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_editView.smallButton addTarget:self action:@selector(editViewSelectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editView;
}


- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        NSArray *ary = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19"];
        [_dataArray addObjectsFromArray:ary];
    }
    return _dataArray;
}

- (NSMutableArray *)deleteDataArray{
    if (!_deleteDataArray) {
        _deleteDataArray = [NSMutableArray array];
    }
    return _deleteDataArray;
}


@end
