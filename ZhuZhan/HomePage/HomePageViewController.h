//
//  HomePageViewController.h
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-5.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewController.h"
#import "ProjectTableViewController.h"
#import "MoreCompanyViewController.h"
#import "QuadCurveMenu.h"
#import "ProductViewController.h"
#import "ALLProjectViewController.h"
#import "ActiveViewController.h"
@interface HomePageViewController : UIViewController<QuadCurveMenuDelegate>{
    UIButton *contactBtn;
    UIButton *projectBtn;
    UIButton *companyBtn;
    UIButton *tradeBtn;
    UIButton *moreBtn;
    UIView *contentView;
    UIView *toolView;
    ContactViewController *contactview;
    ALLProjectViewController *projectview;
    MoreCompanyViewController *companyview;
    ProductViewController *productView;
    UIViewController* testVC;
    UINavigationController *nav;
    QuadCurveMenu *menu;
    UIViewController* quadCurveVC;
    ActiveViewController *activeView;
}
-(void)homePageTabBarHide;
-(void)homePageTabBarRestore;
-(void)BtnClick:(UIButton *)button;

@property(nonatomic)BOOL isOpenContactView;

//category 1为询价 2为报价
- (void)gotoMyAskPriceWithCategory:(NSInteger)category;

//通讯录好友
- (void)gotoAdressBookFriendList;

//会话列表
- (void)gotoChatList;

//我的合同列表
- (void)gotoContracts;
@end
