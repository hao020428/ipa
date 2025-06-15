#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AntiRecording : NSObject

// 开始防录屏检测
- (void)startAntiDetection;

// 停止防录屏检测
- (void)stopAntiDetection;

// 检查是否正在录屏
- (BOOL)isScreenBeingRecorded;

// 添加防录屏层到指定视图
- (void)addAntiRecordingLayerToView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END 