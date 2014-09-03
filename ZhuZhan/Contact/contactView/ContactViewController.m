//
//  ContactViewController.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-5.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import "ContactViewController.h"
#import "CompanyMemberViewController.h"
#import "PersonalCenterViewController.h"
#import "PersonalDetailViewController.h"
#import "LoginModel.h"
#import "PublishViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "RecommendLetterViewController.h"
#import "ContactProjectTableViewCell.h"
#import "ContactTableViewCell.h"
static NSString * const PSTableViewCellIdentifier = @"PSTableViewCellIdentifier";
@interface ContactViewController ()

@end

@implementation ContactViewController
@synthesize showVC,transparent;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        [self setupDatasource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"GurmukhiMN-Bold" size:19], NSFontAttributeName,
                                                                     nil]];
    
    //RightButton设置属性
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 50, 19.5)];
    [rightButton setTitle:@"发布" forState:UIControlStateNormal];
    rightButton.titleLabel.textColor = [UIColor whiteColor];
    [rightButton addTarget:self action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.title = @"人脉";
    
    
    //上拉刷新界面
    _pathCover = [[XHPathCover alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 154)];
    _pathCover.delegate = self;
    [_pathCover setBackgroundImage:[UIImage imageNamed:@"bg001.png"]];
    [_pathCover setAvatarImage:[UIImage imageNamed:@"人脉_29a.png"]];
    [_pathCover setHeadTaget];
    [_pathCover setInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"用户名", XHUserNameKey, @"公司名字显示在这里     职位", XHBirthdayKey, nil]];
    self.tableView.tableHeaderView = self.pathCover;
    //时间标签
    _timeScroller = [[ACTimeScroller alloc] initWithDelegate:self];

    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:PSTableViewCellIdentifier];
    
    self.tableView.separatorStyle = NO;
    
    __weak ContactViewController *wself = self;
    [_pathCover setHandleRefreshEvent:^{
        [wself _refreshing];
    }];
    
    showArr = [[NSMutableArray alloc] init];
    viewArr = [[NSMutableArray alloc] init];
    for(int i=0;i<4;i++){
        CommentModel *model = [[CommentModel alloc] init];
        model.imageUrl = [NSString stringWithFormat:@"bg00%d",i];
        if(i==0){
            model.type = @"project";
        }else if(i==1){
            model.type = @"contact";
        }else{
            model.type = @"main";
        }
        [showArr addObject:model];
    }
    
    for(int i=0;i<showArr.count;i++){
        CommentModel *model = showArr[i];
        if([model.type isEqualToString:@"main"]){
            commentView = [CommentView setFram:model];
            [viewArr insertObject:commentView atIndex:i];
        }else{
            [viewArr insertObject:@"" atIndex:i];
        }
    }
}



-(void)publish
{
    NSLog(@"发布产品");

    PublishViewController *publishVC = [[PublishViewController alloc] init];
    [self.navigationController pushViewController:publishVC animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//设置时间
- (void)setupDatasource
{
    _datasource = [NSMutableArray new];
    for(int i=0;i<30;i++){
        NSTimeInterval interval = 60 * 60 * i;
        [_datasource addObject:[[NSDate date] initWithTimeInterval:interval sinceDate:[NSDate date]]];
    }
}

- (void)_refreshing {
    // refresh your data sources
    __weak ContactViewController *wself = self;
    double delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [wself.pathCover stopRefresh];
    });
}

/******************************************************************************************************************/
//滚动是触发的事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pathCover scrollViewDidScroll:scrollView];
    [_timeScroller scrollViewDidScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_pathCover scrollViewDidEndDecelerating:scrollView];
    [_timeScroller scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pathCover scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_pathCover scrollViewWillBeginDragging:scrollView];
    [_timeScroller scrollViewWillBeginDragging];
}
/******************************************************************************************************************/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [showArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PSTableViewCellIdentifier];
    CommentModel *model = showArr[indexPath.row];
    if([model.type isEqualToString:@"project"]){
        NSString *CellIdentifier = [NSString stringWithFormat:@"ContactProjectTableViewCell"];
        ContactProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[ContactProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = NO;
        return cell;
    }else if ([model.type isEqualToString:@"contact"]){
        NSString *CellIdentifier = [NSString stringWithFormat:@"ContactTableViewCell"];
        ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = NO;
        return cell;
    }else if ([model.type isEqualToString:@"main"]){
        NSString *stringcell = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:stringcell];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringcell] ;
        }
        for(int i=0;i<cell.contentView.subviews.count;i++) {
            [((UIView*)[cell.contentView.subviews objectAtIndex:i]) removeFromSuperview];
        }
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(viewArr.count !=0){
            commentView = [viewArr objectAtIndex:indexPath.row];
            [cell.contentView addSubview:commentView];
        }
        return cell;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentModel *model = showArr[indexPath.row];
    if([model.type isEqualToString:@"project"]||[model.type isEqualToString:@"contact"]){
        return 50;
    }else if([model.type isEqualToString:@"main"]){
        commentView = [viewArr objectAtIndex:indexPath.row];
        return 50;
    }else{
        return 44;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

//时间标签
- (UITableView *)tableViewForTimeScroller:(ACTimeScroller *)timeScroller
{
    return [self tableView];
}
//传入时间标签的date
- (NSDate *)timeScroller:(ACTimeScroller *)timeScroller dateForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    return _datasource[[indexPath row]];
}

//点击自己头像去个人中心
-(void)gotoMyCenter{
    NSLog(@"gotoMyCenter");
    PersonalCenterViewController *personalVC = [[PersonalCenterViewController alloc] init];
    [self.navigationController pushViewController:personalVC animated:YES];
}

-(void)ShowUserPanView:(UIButton *)button{

    showVC = [[ShowViewController alloc] init];
    showVC.delegate =self;
    [showVC.view setFrame:CGRectMake(40, 70, 220, 240)];
    showVC.view.layer.cornerRadius = 10;//设置那个圆角的有多圆
    showVC.view.layer.masksToBounds = YES;//设为NO去试试。设置YES是保证添加的图片覆盖视图的效果
    
    [self presentPopupViewController:showVC animationType:MJPopupViewAnimationFade flag:0];

    
}



- (void)jumpToGoToDetail
{
        NSLog(@"访问个人详情");
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    PersonalDetailViewController *personalVC = [[PersonalDetailViewController alloc] init];
    [self.navigationController pushViewController:personalVC animated:NO];
}

- (void)jumpToGotoConcern
{

        NSLog(@"关注好友");
       [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSLog(@"*******%@",userId);
       NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithObjectsAndKeys:userId,@"userId",@"bfc78202-8ac9-447a-a99d-783606d25668",@"focusId", nil];
    [LoginModel PostInformationImprovedWithBlock:^(NSMutableArray *posts, NSError *error) {
        NSDictionary *responseObject = [posts objectAtIndex:0];
        NSString *statusCode = [[[responseObject objectForKey:@"d"] objectForKey:@"status"] objectForKey:@"statusCode"];
        if ([[NSString stringWithFormat:@"%@",statusCode] isEqualToString:@"1300"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加关注成功" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
            [alert show];
        }
        else if ([[NSString stringWithFormat:@"%@",statusCode] isEqualToString:@"1308"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经添加关注" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"关注失败" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
            [alert show];
        }
        
    } dic:parameter];
}

-(void)jumpToGetRecommend:(NSDictionary *)dic
{
    NSLog(@"获得推荐");
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    RecommendLetterViewController *recommendLetterVC = [[RecommendLetterViewController alloc] init];
    [self.navigationController pushViewController:recommendLetterVC animated:YES];//跳转到推荐信页面
}


@end
