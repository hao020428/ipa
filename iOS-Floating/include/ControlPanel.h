#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ESPToggleCallback)(BOOL enabled);
typedef void(^AimbotToggleCallback)(BOOL enabled);
typedef void(^AimbotTargetCallback)(NSInteger target);
typedef void(^AimbotSpeedCallback)(float speed);

@interface ControlPanel : UIView

// 设置ESP开关回调
- (void)setESPToggleCallback:(ESPToggleCallback)callback;

// 设置自瞄开关回调
- (void)setAimbotToggleCallback:(AimbotToggleCallback)callback;

// 设置自瞄目标回调
- (void)setAimbotTargetCallback:(AimbotTargetCallback)callback;

// 设置自瞄速度回调
- (void)setAimbotSpeedCallback:(AimbotSpeedCallback)callback;

@end

NS_ASSUME_NONNULL_END 