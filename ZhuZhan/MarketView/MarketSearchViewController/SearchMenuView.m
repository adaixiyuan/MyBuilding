//
//  SearchMenuView.m
//  ZhuZhan
//
//  Created by 孙元侃 on 15/5/5.
//
//

#import "SearchMenuView.h"

@interface SearchMenuView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)NSArray* titles;
@property (nonatomic, strong)UITableView* tableView;
@property (nonatomic)CGPoint originPoint;
@end

@implementation SearchMenuView
+ (SearchMenuView*)searchMenuViewWithTitles:(NSArray*)titles originPoint:(CGPoint)originPoint{
    return [[SearchMenuView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) titles:titles originPoint:originPoint];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles originPoint:(CGPoint)originPoint{
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.originPoint = originPoint;
        [self setUp];
    }
    return self;
}

- (void)setUp{
    [self addSubview:self.tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 20;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:.8];
    }
    cell.textLabel.text = self.titles[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(searchMenuViewClickedWithTitle:index:)]) {
        [self.delegate searchMenuViewClickedWithTitle:self.titles[indexPath.row] index:indexPath.row];
    }
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self removeFromSuperview];
}

- (void)dealloc{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (UITableView *)tableView{
    if (!_tableView) {
        CGFloat height = self.titles.count*20+20;
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(self.originPoint.x, self.originPoint.y, 100, height) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
@end
