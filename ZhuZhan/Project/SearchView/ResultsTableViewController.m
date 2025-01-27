//
//  ResultsTableViewController.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-27.
//
//

#import "ResultsTableViewController.h"
#import "ProjectApi.h"
#import "projectModel.h"
#import "ProjectTableViewCell.h"
#import "ProgramDetailViewController.h"
#import "MJRefresh.h"
#import "ConnectionAvailable.h"
#import "MBProgressHUD.h"
#import "ErrorView.h"
#import "MyTableView.h"
#import "PorjectCommentTableViewController.h"
#import "IsFocusedApi.h"

@interface ResultsTableViewController ()<ProjectTableViewCellDelegate,LoginViewDelegate>

@end

@implementation ResultsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //LeftButton设置属性
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 25, 22)];
    [leftButton setBackgroundImage:[GetImagePath getImagePath:@"013"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(0, 0, 240, 31)];
    [searchBtn setBackgroundImage:[GetImagePath getImagePath:@"搜索结果_03a"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(serachClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:searchBtn];
    
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 15, 15)];
    [searchImage setImage:[GetImagePath getImagePath:@"搜索结果_09a"]];
    [bgView addSubview:searchImage];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 200, 30)];
    label.textColor = [UIColor whiteColor];
    if(self.flag == 0){
        label.text = self.searchStr;
    }else{
        NSMutableString *str = [[NSMutableString alloc] init];
        NSString *string = nil;
        for(int i=0;i<self.dic.allKeys.count;i++){
            if(![[self.dic objectForKey:[self.dic allKeys][i]] isEqualToString:@""]){
                [str appendString:[NSString stringWithFormat:@"%@,",[self.dic objectForKey:[self.dic allKeys][i]]]];
            }
        }
        if(str.length !=0){
            string = [str substringToIndex:([str length]-1)];
        }
        
        string =  [string stringByReplacingOccurrencesOfString:@"+" withString:@","];
        label.text = string;
    }
    label.font = [UIFont systemFontOfSize:16];
    [bgView addSubview:label];
    self.navigationItem.titleView = bgView;
    
    startIndex = 0;
    allCount = @"0";
    self.tableView.backgroundColor = AllBackLightGratColor;
    self.tableView.separatorStyle = NO;
    
    //集成刷新控件
    [self setupRefresh];
    [self firstNetWork];
}

-(void)firstNetWork{
    self.tableView.scrollEnabled = NO;
    loadingView = [LoadingView loadingViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view];
    if(self.flag == 0){
        [ProjectApi GetPiProjectSeachWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                if(posts.count !=0){
                    showArr = posts[0];
                    allCount = posts[1];
                }else{
                    showArr = posts[0];
                    allCount = @"0";
                }
                if(showArr.count == 0){
                    [MyTableView reloadDataWithTableView:self.tableView];
                    [MyTableView noSearchData:self.tableView];
                }else{
                    [MyTableView removeFootView:self.tableView];
                    [self.tableView reloadData];
                }
                [LoadingView removeLoadingView:loadingView];
                self.tableView.scrollEnabled = YES;
                loadingView = nil;
            }else{
                if([ErrorCode errorCode:error] == 403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                        [self firstNetWork];
                    }];
                }
                [LoadingView removeLoadingView:loadingView];
                self.tableView.scrollEnabled = YES;
                loadingView = nil;
            }
        } startIndex:startIndex keywords:self.searchStr noNetWork:^{
            [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view reloadBlock:^{
                [self firstNetWork];
            }];
        }];
    }else{
        NSLog(@"==>%@",self.dic);
        [ProjectApi AdvanceSearchProjectsWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                if(posts.count !=0){
                    showArr = posts[0];
                    allCount = posts[1];
                }else{
                    showArr = posts[0];
                    allCount = @"0";
                }
                if(showArr.count == 0){
                    [MyTableView reloadDataWithTableView:self.tableView];
                    [MyTableView noSearchData:self.tableView];
                }else{
                    [MyTableView removeFootView:self.tableView];
                    [self.tableView reloadData];
                }
                [LoadingView removeLoadingView:loadingView];
                self.tableView.scrollEnabled = YES;
                loadingView = nil;
            }else{
                if([ErrorCode errorCode:error] == 403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view reloadBlock:^{
                        [self firstNetWork];
                    }];
                }
                [LoadingView removeLoadingView:loadingView];
                self.tableView.scrollEnabled = YES;
                loadingView = nil;
            }
        } dic:self.dic startIndex:startIndex noNetWork:^{
            [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view reloadBlock:^{
                [self firstNetWork];
            }];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)leftBtnClick{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)serachClick{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    //[_tableView headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    startIndex = 0;
    if(self.flag == 0){
        [ProjectApi GetPiProjectSeachWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                [showArr removeAllObjects];
                if(posts.count !=0){
                    showArr = posts[0];
                    NSLog(@"%@",showArr);
                    allCount = posts[1];
                }else{
                    showArr = posts[0];
                    allCount = @"0";
                }
                if(showArr.count == 0){
                    [MyTableView reloadDataWithTableView:self.tableView];
                    [MyTableView noSearchData:self.tableView];
                }else{
                    [MyTableView removeFootView:self.tableView];
                    [self.tableView reloadData];
                }
            }else{
                if([ErrorCode errorCode:error] == 403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                        [self firstNetWork];
                    }];
                }
            }
            [self.tableView headerEndRefreshing];
        } startIndex:0 keywords:self.searchStr noNetWork:^{
            [self.tableView headerEndRefreshing];
            [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                [self headerRereshing];
            }];
        }];
    }else{
        [ProjectApi AdvanceSearchProjectsWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                [showArr removeAllObjects];
                if(posts.count !=0){
                    showArr = posts[0];
                    allCount = posts[1];
                }else{
                    showArr = posts[0];
                    allCount = @"0";
                }
                if(showArr.count == 0){
                    [MyTableView reloadDataWithTableView:self.tableView];
                    [MyTableView noSearchData:self.tableView];
                }else{
                    [MyTableView removeFootView:self.tableView];
                    [self.tableView reloadData];
                }
            }else{
                if([ErrorCode errorCode:error] == 403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view reloadBlock:^{
                        [self firstNetWork];
                    }];
                }
            }
            [self.tableView headerEndRefreshing];
        } dic:self.dic startIndex:0 noNetWork:^{
            [self.tableView headerEndRefreshing];
            [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                [self headerRereshing];
            }];
        }];
    }
}

- (void)footerRereshing
{
    if(self.flag == 0){
        [ProjectApi GetPiProjectSeachWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                startIndex++;
                if(posts.count !=0){
                    [showArr addObjectsFromArray:posts[0]];
                    allCount = posts[1];
                }else{
                    [showArr addObjectsFromArray:posts[0]];
                    allCount = @"0";
                }
                if(showArr.count == 0){
                    [MyTableView reloadDataWithTableView:self.tableView];
                    [MyTableView noSearchData:self.tableView];
                }else{
                    [MyTableView removeFootView:self.tableView];
                    [self.tableView reloadData];
                }
            }else{
                if([ErrorCode errorCode:error] == 403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                        [self firstNetWork];
                    }];
                }
            }
            [self.tableView footerEndRefreshing];
        } startIndex:startIndex+1 keywords:self.searchStr noNetWork:^{
            [self.tableView footerEndRefreshing];
            [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                [self footerRereshing];
            }];
        }];
    }else{
        [ProjectApi AdvanceSearchProjectsWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                startIndex++;
                if(posts.count !=0){
                    [showArr addObjectsFromArray:posts[0]];
                    allCount = posts[1];
                }else{
                    [showArr addObjectsFromArray:posts[0]];
                    allCount = @"0";
                }
                if(showArr.count == 0){
                    [MyTableView reloadDataWithTableView:self.tableView];
                    [MyTableView noSearchData:self.tableView];
                }else{
                    [MyTableView removeFootView:self.tableView];
                    [self.tableView reloadData];
                }
                [self.tableView footerEndRefreshing];
            }else{
                if([ErrorCode errorCode:error] == 403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorView errorViewWithFrame:CGRectMake(0, 0, 320, kScreenHeight) superView:self.view reloadBlock:^{
                        [self firstNetWork];
                    }];
                }
            }
        } dic:self.dic startIndex:startIndex+1 noNetWork:^{
            [self.tableView footerEndRefreshing];
            [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, kScreenHeight-64) superView:self.view reloadBlock:^{
                [self footerRereshing];
            }];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return showArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 30;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize defaultSize = DEFAULT_CELL_SIZE;
    CGSize cellSize = [ProjectTableViewCell sizeForCellWithDefaultSize:defaultSize setupCellBlock:^id(id<CellHeightDelegate> cellToSetup) {
        projectModel *model = showArr[indexPath.row];
        [((ProjectTableViewCell *)cellToSetup) setModel:model];
        return cellToSetup;
    }];
    return cellSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"ProjectTableViewCell"];
    ProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    projectModel *model = showArr[indexPath.row];
    if(!cell){
        cell = [[ProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.model = model;
    cell.delegate = self;
    cell.selectionStyle = NO;
    cell.indexPath = indexPath;
    cell.isHiddenFocusBtn = NO;
    cell.isHiddenApproveImageView = YES;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 291.5, 50)];
        [bgView setBackgroundColor:AllBackLightGratColor];
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 160, 20)];
        countLabel.font = [UIFont systemFontOfSize:12];
        countLabel.textColor = GrayColor;
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.text = [NSString stringWithFormat:@"共计%@条",allCount];
        [bgView addSubview:countLabel];
        return bgView;
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProgramDetailViewController* vc=[[ProgramDetailViewController alloc]init];
    projectModel *model = showArr[indexPath.row];
    vc.projectId=model.a_id;
    vc.isFocused = model.isFocused;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)gotoLoginView{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.needDelayCancel=YES;
    loginVC.delegate = self;
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self.view.window.rootViewController presentViewController:nv animated:YES completion:nil];
}

-(void)loginCompleteWithDelayBlock:(void (^)())block{
    startIndex = 0;
    [showArr removeAllObjects];
    [self firstNetWork];
    if (block) {
        block();
    }
}

-(void)addFocused:(NSIndexPath *)indexPath{
    projectModel *model = showArr[indexPath.row];
    if([model.isFocused isEqualToString:@"0"]){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:model.a_id forKey:@"targetId"];
        [dic setObject:@"03" forKey:@"targetCategory"];
        [IsFocusedApi AddFocusedListWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"关注成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                model.isFocused = @"1";
                [showArr replaceObjectAtIndex:indexPath.row withObject:model];
                [self.tableView reloadData];
            }else{
                if([ErrorCode errorCode:error] == 403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorCode alert];
                }
            }
        } dic:dic noNetWork:nil];
    }else{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:model.a_id forKey:@"targetId"];
        [dic setObject:@"03" forKey:@"targetCategory"];
        [IsFocusedApi AddFocusedListWithBlock:^(NSMutableArray *posts, NSError *error) {
            if(!error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"取消关注成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                model.isFocused = @"0";
                [showArr replaceObjectAtIndex:indexPath.row withObject:model];
                [self.tableView reloadData];
            }else{
                if([ErrorCode errorCode:error] == 403){
                    [LoginAgain AddLoginView:NO];
                }else{
                    [ErrorCode alert];
                }
            }
        } dic:dic noNetWork:^{
            [ErrorCode alert];
        }];
    }
}
@end
