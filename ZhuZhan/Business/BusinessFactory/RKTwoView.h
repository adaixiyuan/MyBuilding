//
//  RKTwoView.h
//  ZhuZhan
//
//  Created by 孙元侃 on 15/3/17.
//
//

#import <UIKit/UIKit.h>

typedef enum RKTwoViewAssistViewMode{
    RKTwoViewAssistViewModeIsLabel,
    RKTwoViewAssistViewModeIsbutton
}RKTwoViewAssistViewMode;

typedef enum RKTwoViewWidthMode{
    RKTwoViewWidthModeWholeLine=1,
    RKTwoViewWidthModeHalfLine
}RKTwoViewWidthMode;

@interface RKTwoView : UIView
+(RKTwoView*)twoViewWithViewMode:(RKTwoViewWidthMode)viewMode assistMode:(RKTwoViewAssistViewMode)assistMode leftContent:(NSString*)leftContent rightContent:(NSString*)rightContent needAuto:(BOOL)needAuto;

-(void)rightLabelMoveX:(CGFloat)x y:(CGFloat)y reduceWidth:(CGFloat)reduceWidth;

+(CGFloat)carculateTotalHeightWithContents:(NSArray*)array;
+(CGFloat)carculateNormalTotalHeightWithNumber:(NSInteger)number;
@end
