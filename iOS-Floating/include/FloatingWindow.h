#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FloatingWindow : NSObject

// 显示悬浮窗
- (void)show;

// 隐藏悬浮窗
- (void)hide;

// 设置悬浮窗透明度
- (void)setOpacity:(float)opacity;

// 调整悬浮窗显示位置
- (void)moveToPosition:(CGPoint)position;

// 切换ESP绘制状态 (透视功能)
- (void)toggleESP:(BOOL)enabled;

// 切换自瞄状态
- (void)toggleAimbot:(BOOL)enabled;

// 设置自瞄目标的部位 (头部/胸部)
- (void)setAimbotTarget:(NSInteger)target;

// 设置自瞄速度
- (void)setAimbotSpeed:(float)speed;

@end

NS_ASSUME_NONNULL_END