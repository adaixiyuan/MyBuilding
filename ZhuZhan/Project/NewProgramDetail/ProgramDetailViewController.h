//
//  ProgramDetailViewController.h
//  ZhuZhan
//
//  Created by 孙元侃 on 14-8-26.
//
//

#import <UIKit/UIKit.h>
#import "projectModel.h"
#import "ChatBaseViewController.h"
@interface ProgramDetailViewController : ChatBaseViewController
@property(nonatomic,strong)NSString *projectId;
@property(nonatomic,strong)NSString* isFocused;
@end
