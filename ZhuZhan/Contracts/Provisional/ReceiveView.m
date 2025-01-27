//
//  ReceiveView.m
//  ZhuZhan
//
//  Created by 汪洋 on 15/3/30.
//
//

#import "ReceiveView.h"
#import "RKShadowView.h"
@implementation ReceiveView
-(id)initWithFrame:(CGRect)frame isModified:(BOOL)isModified{
    self = [super initWithFrame:frame];
    if(self){
        [self addCutLine];
        [self.addPersona addSubview:self.personaLabel];
        [self.addPersona addSubview:self.addImageView];
        [self addSubview:self.addPersona];
        [self addSubview:self.contactBtn];
        [self.contactBtn addSubview:self.arrowImageView];
        [self.contactBtn addSubview:self.contactLabel];
        [self addSubview:self.textField];
        [self addSubview:self.messageLabel];
        [self addSubview:self.bottomView];
        if(isModified){
            self.addPersona.enabled = NO;
            self.contactBtn.enabled = NO;
            self.textField.enabled = NO;
        }
    }
    return self;
}

-(UIButton *)addPersona{
    if(!_addPersona){
        _addPersona = [UIButton buttonWithType:UIButtonTypeCustom];
        _addPersona.frame = CGRectMake(0, 0, 320, 47);
        [_addPersona addTarget:self action:@selector(addPersonaAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addPersona;
}

-(UILabel *)personaLabel{
    if(!_personaLabel){
        _personaLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 180, 16)];
        _personaLabel.textAlignment = NSTextAlignmentLeft;
        _personaLabel.textColor = BlueColor;
        _personaLabel.text = @"请选择接受者的用户名";
        _personaLabel.font = [UIFont systemFontOfSize:16];
    }
    return _personaLabel;
}

-(UIImageView *)addImageView{
    if(!_addImageView){
        _addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(287, 16, 9, 15)];
        _addImageView.image = [GetImagePath getImagePath:@"交易_箭头"];
    }
    return _addImageView;
}

-(UIButton *)contactBtn{
    if(!_contactBtn){
        _contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _contactBtn.frame = CGRectMake(0, 49, 320, 47);
        [_contactBtn addTarget:self action:@selector(contactBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contactBtn;
}

-(UIImageView *)arrowImageView{
    if(!_arrowImageView){
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(287, 16, 9, 15)];
        _arrowImageView.image = [GetImagePath getImagePath:@"交易_箭头"];
    }
    return _arrowImageView;
}

-(UILabel *)contactLabel{
    if(!_contactLabel){
        _contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 200, 16)];
        _contactLabel.text = @"选择合同角色";
        _contactLabel.textColor = BlueColor;
        _contactLabel.font = [UIFont systemFontOfSize:16];
    }
    return _contactLabel;
}

-(UITextField *)textField{
    if(!_textField){
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 97, 320, 47)];
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
        _textField.leftView.userInteractionEnabled = NO;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.placeholder = @"可以输入个人/企业名称";
        _textField.font = [UIFont systemFontOfSize:15];
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
        [_textField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    }
    return _textField;
}

-(UILabel *)messageLabel{
    if(!_messageLabel){
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 145, 250, 16)];
        _messageLabel.textColor = [UIColor redColor];
        _messageLabel.text = @"这里填写的内容将会用于发表在合同中";
        _messageLabel.font = [UIFont systemFontOfSize:13];
    }
    return _messageLabel;
}

-(UIView *)bottomView{
    if(!_bottomView){
        _bottomView = [RKShadowView seperatorLineShadowViewWithHeight:10];
        _bottomView.frame = CGRectMake(0, 170, 320, 10);
    }
    return _bottomView;
}

-(void)addCutLine{
    for(int i=0;i<2;i++){
        self.cutLine = [RKShadowView seperatorLine];
        self.cutLine.frame = CGRectMake(0, 48*i+48, 320, 1);
        [self addSubview:self.cutLine];
    }
}

-(void)addPersonaAction{
    if([self.delegate respondsToSelector:@selector(showSearchView)]){
        [self.delegate showSearchView];
    }
}

-(void)contactBtnAction{
    if([self.delegate respondsToSelector:@selector(showActionSheet:)]){
        [self.delegate showActionSheet:1];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if([self.delegate respondsToSelector:@selector(textFiedDidBegin:)]){
        [self.delegate textFiedDidBegin:textField];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if([self.delegate respondsToSelector:@selector(textFiedDidEnd:textField:)]){
        [self.delegate textFiedDidEnd:textField.text textField:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textField resignFirstResponder];
    return YES;
}
@end
