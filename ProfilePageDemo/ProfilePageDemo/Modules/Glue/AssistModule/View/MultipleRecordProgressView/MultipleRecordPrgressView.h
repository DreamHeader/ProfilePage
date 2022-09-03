//
//  CustomProgress.swift
//  unipets-ios
//
//  Created by Future on 2021/12/2.
//

#import <UIKit/UIKit.h>

@interface MultipleRecordPrgressView : UIView
@property (nonatomic, assign) CGFloat progressEnd;
@property (nonatomic, strong) UIColor *pauseColor;
@property (nonatomic, strong) UIColor *drawColor;
@property (nonatomic, strong) NSMutableArray *nowArray;/*最后一段录制的红点绘制*/
@property (nonatomic, strong) NSMutableArray *pauseArray;/*绘制白点*/
@property (nonatomic, strong) NSArray *allArray;/*前面分段录制*/
/** 起始 */
- (void)drawBegan;
/** 过程 */
- (void)drawMoved;
/** 暂停 */
- (void)drawPause;
/** 结束 */
- (void)drawEnded;
/** 复位 */
- (void)drawReset;
/** 删除上一段 */
-(void)drawDeleteLastProgress;
 
@end

