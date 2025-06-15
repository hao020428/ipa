#import "../../include/FloatingWindow.h"
#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "../../include/DrawingView.h"
#import "../../include/ControlPanel.h"

@interface FloatingWindow () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWindow *floatingWindow;
@property (nonatomic, strong) DrawingView *drawingView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) ControlPanel *controlPanel;
@property (nonatomic, assign) CGFloat initialAlpha;
@property (nonatomic, assign) BOOL espEnabled;
@property (nonatomic, assign) BOOL aimbotEnabled;
@property (nonatomic, assign) NSInteger aimbotTarget;
@property (nonatomic, assign) CGFloat aimbotSpeed;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation FloatingWindow

#pragma mark - 初始化方法

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始设置
        _initialAlpha = 0.8;
        _espEnabled = NO;
        _aimbotEnabled = NO;
        _aimbotTarget = 0; // 0:头部, 1:胸部
        _aimbotSpeed = 0.5; // 默认速度
        
        [self setupFloatingWindow];
        [self setupDisplayLink];
    }
    return self;
}

#pragma mark - 设置方法

- (void)setupFloatingWindow {
    // 创建一个新的窗口，级别设置为UIWindowLevelStatusBar + 1
    self.floatingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 100, 60, 60)];
    self.floatingWindow.windowLevel = UIWindowLevelStatusBar + 1;
    self.floatingWindow.backgroundColor = [UIColor clearColor];
    self.floatingWindow.layer.cornerRadius = 30;
    self.floatingWindow.layer.masksToBounds = YES;
    self.floatingWindow.alpha = self.initialAlpha;
    self.floatingWindow.clipsToBounds = YES;
    
    // 创建按钮作为悬浮窗的控制点
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(0, 0, 60, 60);
    self.menuButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:0.8];
    [self.menuButton setTitle:@"菜单" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.menuButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    self.menuButton.layer.cornerRadius = 30;
    self.menuButton.layer.masksToBounds = YES;
    
    // 添加点击事件
    [self.menuButton addTarget:self action:@selector(menuButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加拖动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [self.menuButton addGestureRecognizer:panGesture];
    
    // 添加到悬浮窗中
    [self.floatingWindow addSubview:self.menuButton];
    
    // 设置绘制视图(全屏但透明的)
    self.drawingView = [[DrawingView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.drawingView.backgroundColor = [UIColor clearColor];
    self.drawingView.userInteractionEnabled = NO;
    [self.floatingWindow addSubview:self.drawingView];
    [self.floatingWindow sendSubviewToBack:self.drawingView];
    
    // 创建控制面板(隐藏)
    self.controlPanel = [[ControlPanel alloc] initWithFrame:CGRectMake(10, 100, 300, 400)];
    self.controlPanel.hidden = YES;
    [self.floatingWindow addSubview:self.controlPanel];
    
    // 设置控制面板回调
    __weak typeof(self) weakSelf = self;
    [self.controlPanel setESPToggleCallback:^(BOOL enabled) {
        [weakSelf toggleESP:enabled];
    }];
    [self.controlPanel setAimbotToggleCallback:^(BOOL enabled) {
        [weakSelf toggleAimbot:enabled];
    }];
    [self.controlPanel setAimbotTargetCallback:^(NSInteger target) {
        [weakSelf setAimbotTarget:target];
    }];
    [self.controlPanel setAimbotSpeedCallback:^(float speed) {
        [weakSelf setAimbotSpeed:speed];
    }];
}

- (void)setupDisplayLink {
    // 设置显示链接以便在每一帧上更新绘图
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDrawing)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - 公共方法

- (void)show {
    self.floatingWindow.hidden = NO;
}

- (void)hide {
    self.floatingWindow.hidden = YES;
}

- (void)setOpacity:(float)opacity {
    self.initialAlpha = opacity;
    self.floatingWindow.alpha = opacity;
}

- (void)moveToPosition:(CGPoint)position {
    self.floatingWindow.frame = CGRectMake(position.x, position.y, 
                                          self.floatingWindow.frame.size.width, 
                                          self.floatingWindow.frame.size.height);
}

- (void)toggleESP:(BOOL)enabled {
    self.espEnabled = enabled;
    self.drawingView.espEnabled = enabled;
}

- (void)toggleAimbot:(BOOL)enabled {
    self.aimbotEnabled = enabled;
    self.drawingView.aimbotEnabled = enabled;
}

- (void)setAimbotTarget:(NSInteger)target {
    self.aimbotTarget = target;
    self.drawingView.aimbotTarget = target;
}

- (void)setAimbotSpeed:(float)speed {
    self.aimbotSpeed = speed;
    self.drawingView.aimbotSpeed = speed;
}

#pragma mark - 事件处理

- (void)menuButtonTapped {
    // 显示或隐藏控制面板
    self.controlPanel.hidden = !self.controlPanel.hidden;
    
    if (!self.controlPanel.hidden) {
        // 更新控制面板位置
        CGRect buttonFrame = self.menuButton.frame;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        CGFloat panelX = buttonFrame.origin.x + buttonFrame.size.width + 10;
        if (panelX + self.controlPanel.frame.size.width > screenBounds.size.width) {
            panelX = buttonFrame.origin.x - self.controlPanel.frame.size.width - 10;
        }
        
        CGFloat panelY = buttonFrame.origin.y;
        if (panelY + self.controlPanel.frame.size.height > screenBounds.size.height) {
            panelY = screenBounds.size.height - self.controlPanel.frame.size.height - 10;
        }
        
        self.controlPanel.frame = CGRectMake(panelX, panelY, 
                                            self.controlPanel.frame.size.width, 
                                            self.controlPanel.frame.size.height);
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.floatingWindow];
    
    // 更新悬浮窗位置
    CGPoint newCenter = CGPointMake(self.floatingWindow.center.x + translation.x,
                                    self.floatingWindow.center.y + translation.y);
    
    // 确保不会移出屏幕
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat halfWidth = self.floatingWindow.frame.size.width / 2;
    CGFloat halfHeight = self.floatingWindow.frame.size.height / 2;
    
    newCenter.x = MAX(halfWidth, MIN(screenBounds.size.width - halfWidth, newCenter.x));
    newCenter.y = MAX(halfHeight, MIN(screenBounds.size.height - halfHeight, newCenter.y));
    
    self.floatingWindow.center = newCenter;
    [gesture setTranslation:CGPointZero inView:self.floatingWindow];
    
    // 隐藏控制面板，如果正在显示
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.controlPanel.hidden = YES;
    }
}

#pragma mark - 绘制更新

- (void)updateDrawing {
    if (self.espEnabled || self.aimbotEnabled) {
        // 刷新绘制视图
        [self.drawingView setNeedsDisplay];
        
        // 如果需要绘制全屏内容，更新绘制视图的位置到全屏
        if (self.drawingView.superview != [UIApplication sharedApplication].keyWindow) {
            [self.drawingView removeFromSuperview];
            
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            self.drawingView.frame = keyWindow.bounds;
            [keyWindow addSubview:self.drawingView];
            [keyWindow bringSubviewToFront:self.floatingWindow];
        }
    }
}

#pragma mark - 内存管理

- (void)dealloc {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

@end 