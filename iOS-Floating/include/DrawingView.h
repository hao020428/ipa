#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawingView : UIView

@property (nonatomic, assign) BOOL espEnabled;
@property (nonatomic, assign) BOOL aimbotEnabled;
@property (nonatomic, assign) NSInteger aimbotTarget;
@property (nonatomic, assign) CGFloat aimbotSpeed;

@end

NS_ASSUME_NONNULL_END 