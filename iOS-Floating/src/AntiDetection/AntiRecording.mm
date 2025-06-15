#import "../../include/AntiRecording.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface AntiRecording ()

@property (nonatomic, assign) BOOL isDetecting;
@property (nonatomic, strong) NSTimer *detectionTimer;
@property (nonatomic, strong) CALayer *antiRecordingLayer;
@property (nonatomic, strong) id<MTLDevice> metalDevice;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, assign) float flickerRate;

@end

@implementation AntiRecording

- (instancetype)init {
    self = [super init];
    if (self) {
        _isDetecting = NO;
        _flickerRate = 0.016; // ~60fps
        
        // 初始化Metal设备和命令队列
        _metalDevice = MTLCreateSystemDefaultDevice();
        if (_metalDevice) {
            _commandQueue = [_metalDevice newCommandQueue];
        }
        
        // 创建防录屏图层
        [self setupAntiRecordingLayer];
        
        // 监听录屏状态变化通知
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(screenCaptureDidChange:) 
                                                     name:UIScreenCapturedDidChangeNotification 
                                                   object:nil];
    }
    return self;
}

- (void)setupAntiRecordingLayer {
    self.antiRecordingLayer = [CALayer layer];
    self.antiRecordingLayer.opacity = 0.0; // 默认不可见
    
    // 设置每像素渲染方式，使其只能被人眼看见
    // 在实际项目中，这里应该使用更复杂的Metal着色器
}

- (void)startAntiDetection {
    if (self.isDetecting) {
        return;
    }
    
    self.isDetecting = YES;
    
    // 开始定时检测
    self.detectionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                          target:self 
                                                        selector:@selector(checkForScreenRecording) 
                                                        userInfo:nil 
                                                         repeats:YES];
    
    // 立即检查一次
    [self checkForScreenRecording];
    
    // 如果设备支持Metal，启动Metal防录屏技术
    if (self.metalDevice) {
        [self startMetalAntiRecording];
    }
}

- (void)stopAntiDetection {
    if (!self.isDetecting) {
        return;
    }
    
    self.isDetecting = NO;
    
    // 停止定时器
    [self.detectionTimer invalidate];
    self.detectionTimer = nil;
    
    // 停止Metal防录屏
    if (self.metalDevice) {
        [self stopMetalAntiRecording];
    }
}

- (BOOL)isScreenBeingRecorded {
    return [UIScreen mainScreen].captured;
}

- (void)addAntiRecordingLayerToView:(UIView *)view {
    // 先移除之前可能添加的图层
    [self.antiRecordingLayer removeFromSuperlayer];
    
    // 设置图层大小与视图一致
    self.antiRecordingLayer.frame = view.bounds;
    
    // 添加图层
    [view.layer addSublayer:self.antiRecordingLayer];
    
    // 根据当前录屏状态设置图层可见性
    [self updateLayerVisibility];
}

#pragma mark - 私有方法

- (void)screenCaptureDidChange:(NSNotification *)notification {
    [self updateLayerVisibility];
    
    // 如果检测到录屏开始或结束，增强防护
    if ([self isScreenBeingRecorded]) {
        [self enhanceAntiRecordingMeasures];
    } else {
        [self resetAntiRecordingMeasures];
    }
}

- (void)checkForScreenRecording {
    static BOOL lastRecordingState = NO;
    BOOL currentRecordingState = [self isScreenBeingRecorded];
    
    // 录屏状态发生变化
    if (lastRecordingState != currentRecordingState) {
        lastRecordingState = currentRecordingState;
        
        if (currentRecordingState) {
            NSLog(@"屏幕录制已启动");
            [self enhanceAntiRecordingMeasures];
        } else {
            NSLog(@"屏幕录制已停止");
            [self resetAntiRecordingMeasures];
        }
    }
    
    [self updateLayerVisibility];
}

- (void)updateLayerVisibility {
    if ([self isScreenBeingRecorded]) {
        // 录屏时激活防录屏层
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.antiRecordingLayer.opacity = 0.01; // 人眼几乎不可见，但足以干扰录屏
        [CATransaction commit];
        
        // 启动闪烁
        [self startLayerFlickering];
    } else {
        // 非录屏时隐藏防录屏层
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.antiRecordingLayer.opacity = 0.0;
        [CATransaction commit];
        
        // 停止闪烁
        [self stopLayerFlickering];
    }
}

- (void)enhanceAntiRecordingMeasures {
    // 发现正在录屏，增强防录屏措施
    
    // 1. 加快闪烁频率
    self.flickerRate = 0.008; // ~120fps
    
    // 2. 使用Metal实现更高级的防录屏效果
    if (self.metalDevice) {
        [self enhanceMetalAntiRecording];
    }
    
    // 3. 可以添加其他防录屏技术
}

- (void)resetAntiRecordingMeasures {
    // 重置防录屏措施到正常状态
    self.flickerRate = 0.016; // ~60fps
    
    if (self.metalDevice) {
        [self resetMetalAntiRecording];
    }
}

#pragma mark - 闪烁控制

- (void)startLayerFlickering {
    // 防止重复启动
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(flickerLayer) object:nil];
    
    // 开始闪烁
    [self flickerLayer];
}

- (void)stopLayerFlickering {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(flickerLayer) object:nil];
}

- (void)flickerLayer {
    if (![self isScreenBeingRecorded]) {
        return;
    }
    
    // 快速切换图层不透明度，以特定频率，使其对录屏造成干扰但人眼几乎察觉不到
    static BOOL isFlickering = NO;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.antiRecordingLayer.opacity = isFlickering ? 0.02 : 0.01;
    [CATransaction commit];
    
    isFlickering = !isFlickering;
    
    // 以设定的频率继续闪烁
    [self performSelector:@selector(flickerLayer) withObject:nil afterDelay:self.flickerRate];
}

#pragma mark - Metal相关代码

- (void)startMetalAntiRecording {
    // 实际项目中，这里应该启动使用Metal创建的特殊渲染管道
    // 这可能涉及到自定义的Metal着色器和渲染通道
    
    // 此代码仅为占位，实际实现需要深入Metal框架
    NSLog(@"开始Metal防录屏处理");
}

- (void)stopMetalAntiRecording {
    // 停止Metal渲染，释放相关资源
    NSLog(@"停止Metal防录屏处理");
}

- (void)enhanceMetalAntiRecording {
    // 增强Metal渲染效果，比如更改着色器参数等
    NSLog(@"增强Metal防录屏效果");
}

- (void)resetMetalAntiRecording {
    // 重置Metal渲染效果
    NSLog(@"重置Metal防录屏效果");
}

- (void)dealloc {
    [self stopAntiDetection];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end 