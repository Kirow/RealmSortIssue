//
//  ViewController.m
//  RealmSortIssue
//
//  Created by KirowOnet on 8/16/17.
//  Copyright © 2017 Home. All rights reserved.
//

#import "ViewController.h"
#import "MyObject.h"
#import "GUID.h"
@import Realm;

#define DATA_SOURCE_SIZE 1000000

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RLMResults *dataSource;
@end

@implementation ViewController

- (RLMResults *)dataSource {
    if(!_dataSource){
        _dataSource = [[MyObject allObjects] sortedResultsUsingKeyPath:@"name" ascending:YES];
    }
    return _dataSource;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    NSUInteger count = self.dataSource.count;
    if(count < DATA_SOURCE_SIZE) {
        [self.dataSource.realm transactionWithBlock:^{
            for (int i = count; i < DATA_SOURCE_SIZE; ++i) {
                MyObject *obj = [MyObject new];
                obj.name = [GUID randomGuid].stringValue;
                [self.dataSource.realm addObject:obj];
            }
        }];
    }

    [self.tableView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;

    }
    MyObject *obj = (MyObject *) self.dataSource[indexPath.row];
    cell.textLabel.text = obj.name;
    cell.accessoryType = obj.flag ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyObject *obj = (MyObject *) self.dataSource[indexPath.row];
    [obj.realm transactionWithBlock:^{
        obj.flag = !obj.flag;
    }];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = obj.flag ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
