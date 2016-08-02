//
//  TableViewController.m
//  YYJavaScriopCoreDemo
//
//  Created by YaoYaoX on 16/7/22.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "TableViewController.h"
#import "BasicUseController.h"
#import "JSOCViewController.h"

@interface TableViewController ()

@property (nonatomic, strong) NSArray *titleStr;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"使用";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.titleStr = @[@"基本使用", @"实战"];
}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleStr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"reuseIdentifier";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = self.titleStr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        BasicUseController *buc = [[BasicUseController alloc] init];
        [self.navigationController pushViewController:buc animated:YES];
    } else if (indexPath.row == 1){
        JSOCViewController *jsVC = [[JSOCViewController alloc]init];
        [self.navigationController pushViewController:jsVC animated:YES];
    }
}
@end
