//
//  SearchContactTableViewCell.m
//  ZhuZhan
//
//  Created by 汪洋 on 15/3/19.
//
//

#import "SearchContactTableViewCell.h"
#define seperatorLineColor RGBCOLOR(229, 229, 229)

@implementation SearchContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.companyName];
        [self.contentView addSubview:self.lineImageView];
    }
    return self;
}

-(UILabel *)companyName{
    if(!_companyName){
        _companyName = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 280, 20)];
        _companyName.font = [UIFont systemFontOfSize:16];
    }
    return _companyName;
}

-(UIImageView *)lineImageView{
    if(!_lineImageView){
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        _lineImageView.backgroundColor = seperatorLineColor;
    }
    return _lineImageView;
}

-(void)setModel:(UserOrCompanyModel *)model{
    if([model.a_nickName isEqualToString:@""]){
        self.companyName.text = model.a_loginName;
    }else{
        self.companyName.text = [NSString stringWithFormat:@"%@ (%@)",model.a_loginName,model.a_nickName];
    }
}

+(UIView *)fullSeperatorLine{
    UIView* seperatorLine=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    seperatorLine.backgroundColor=seperatorLineColor;
    return seperatorLine;
}
@end
