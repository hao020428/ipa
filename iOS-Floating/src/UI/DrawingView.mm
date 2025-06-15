#import "../../include/DrawingView.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "../../include/AntiRecording.h"

// 用于演示的玩家数据结构
typedef struct {
    CGPoint position;      // 屏幕上的位置
    CGFloat width;         // 方框宽度
    CGFloat height;        // 方框高度
    CGFloat health;        // 血量 (0-100)
    CGFloat distance;      // 距离
    BOOL isVisible;        // 是否可见
    BOOL isTeammate;       // 是否是队友
    NSString *name;        // 玩家名字
} PlayerInfo;

@interface DrawingView ()

@property (nonatomic, strong) NSArray<PlayerInfo *> *mockPlayers;
@property (nonatomic, strong) CAShapeLayer *espLayer;
@property (nonatomic, strong) CAShapeLayer *antiRecordingLayer;
@property (nonatomic, assign) BOOL isRecording;

@end

@implementation DrawingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // 初始化ESP层
        self.espLayer = [CAShapeLayer layer];
        self.espLayer.frame = self.bounds;
        self.espLayer.opacity = 1.0;
        [self.layer addSublayer:self.espLayer];
        
        // 初始化防录屏层
        self.antiRecordingLayer = [CAShapeLayer layer];
        self.antiRecordingLayer.frame = self.bounds;
        self.antiRecordingLayer.opacity = 0.0; // 人眼不可见，但会干扰录屏
        [self.layer addSublayer:self.antiRecordingLayer];
        
        // 模拟玩家数据，实际项目中这些数据应该从游戏中读取
        [self createMockPlayers];
        
        // 设置防录屏检测
        [self setupAntiRecordingDetection];
    }
    return self;
}

- (void)createMockPlayers {
    // 创建一些模拟数据，在实际项目中替换为真实游戏数据
    NSMutableArray *players = [NSMutableArray array];
    
    // 创建10个随机位置的玩家
    for (int i = 0; i < 10; i++) {
        PlayerInfo *player = [[PlayerInfo alloc] init];
        
        CGFloat x = 100 + (arc4random() % ((int)self.bounds.size.width - 200));
        CGFloat y = 100 + (arc4random() % ((int)self.bounds.size.height - 200));
        
        player.position = CGPointMake(x, y);
        player.width = 30 + (arc4random() % 20); // 30-50宽度
        player.height = 80 + (arc4random() % 40); // 80-120高度
        player.health = 20 + (arc4random() % 80); // 20-100血量
        player.distance = 20 + (arc4random() % 280); // 20-300距离
        player.isVisible = (arc4random() % 100) < 80; // 80%几率可见
        player.isTeammate = (arc4random() % 100) < 30; // 30%几率是队友
        player.name = [NSString stringWithFormat:@"Player%d", i+1];
        
        [players addObject:player];
    }
    
    self.mockPlayers = players;
}

- (void)setupAntiRecordingDetection {
    // 监听是否正在录屏，调整绘制方式
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(screenCaptureChanged:) 
                   name:UIScreenCapturedDidChangeNotification 
                 object:nil];
    
    // 获取当前录屏状态
    self.isRecording = [UIScreen mainScreen].captured;
    
    // 更新防录屏图层
    [self updateAntiRecordingLayer];
}

- (void)screenCaptureChanged:(NSNotification *)notification {
    // 更新录屏状态
    self.isRecording = [UIScreen mainScreen].captured;
    
    // 更新防录屏图层
    [self updateAntiRecordingLayer];
}

- (void)updateAntiRecordingLayer {
    if (self.isRecording) {
        // 一旦检测到录屏，激活防御措施
        
        // 方法1: 将正常绘制置空，并使用特殊方式绘制
        self.espLayer.opacity = 0.0; 
        
        // 方法2: 使用Metal着色器在系统录屏不可见的模式下绘制（实际代码中需添加Metal实现）
        
        // 方法3: 添加干扰图层让录屏变得无效
        self.antiRecordingLayer.opacity = 0.01; // 对人眼几乎不可见
    } else {
        // 正常模式
        self.espLayer.opacity = 1.0;
        self.antiRecordingLayer.opacity = 0.0;
    }
}

- (void)drawRect:(CGRect)rect {
    // 当正在录屏时，切换到特殊的绘制模式
    if (self.isRecording) {
        [self drawAntiRecordingModeInRect:rect];
        return;
    }
    
    // 正常绘制模式
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 如果未启用ESP，则不绘制
    if (!self.espEnabled) {
        return;
    }
    
    // 绘制所有模拟玩家
    for (PlayerInfo *player in self.mockPlayers) {
        // 如果不可见则跳过
        if (!player.isVisible) {
            continue;
        }
        
        // 设置颜色：队友为绿色，敌人为红色
        UIColor *boxColor = player.isTeammate ? 
            [UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:0.8] : 
            [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.8];
        
        CGContextSetStrokeColorWithColor(context, boxColor.CGColor);
        CGContextSetLineWidth(context, 1.5);
        
        // 绘制方框
        CGRect playerBox = CGRectMake(
            player.position.x - player.width/2, 
            player.position.y - player.height/2, 
            player.width, 
            player.height
        );
        CGContextStrokeRect(context, playerBox);
        
        // 绘制血条背景
        CGFloat healthBarHeight = 5.0;
        CGFloat healthBarY = playerBox.origin.y - healthBarHeight - 2;
        CGRect healthBarBg = CGRectMake(
            playerBox.origin.x, 
            healthBarY, 
            playerBox.size.width, 
            healthBarHeight
        );
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextFillRect(context, healthBarBg);
        
        // 绘制血条
        UIColor *healthColor;
        if (player.health > 70) {
            healthColor = [UIColor greenColor];
        } else if (player.health > 30) {
            healthColor = [UIColor yellowColor];
        } else {
            healthColor = [UIColor redColor];
        }
        
        CGContextSetFillColorWithColor(context, healthColor.CGColor);
        CGRect healthBar = CGRectMake(
            healthBarBg.origin.x, 
            healthBarBg.origin.y, 
            healthBarBg.size.width * (player.health / 100.0), 
            healthBarBg.size.height
        );
        CGContextFillRect(context, healthBar);
        
        // 绘制名字和距离
        NSString *infoText = [NSString stringWithFormat:@"%@ [%.0fm]", 
                              player.name, player.distance];
        
        NSDictionary *textAttrs = @{
            NSFontAttributeName: [UIFont systemFontOfSize:10],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        
        CGSize textSize = [infoText sizeWithAttributes:textAttrs];
        CGRect textRect = CGRectMake(
            playerBox.origin.x + (playerBox.size.width - textSize.width) / 2,
            playerBox.origin.y - textSize.height - 10,
            textSize.width,
            textSize.height
        );
        
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
        CGContextFillRect(context, CGRectInset(textRect, -2, -2));
        [infoText drawInRect:textRect withAttributes:textAttrs];
    }
    
    // 如果启用了自瞄，绘制准星
    if (self.aimbotEnabled) {
        [self drawAimbotCrosshair:context];
    }
}

- (void)drawAimbotCrosshair:(CGContextRef)context {
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    
    // 绘制自瞄准星
    CGFloat crosshairSize = 20.0;
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    // 绘制十字准星
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center.x - crosshairSize, center.y);
    CGContextAddLineToPoint(context, center.x + crosshairSize, center.y);
    CGContextMoveToPoint(context, center.x, center.y - crosshairSize);
    CGContextAddLineToPoint(context, center.x, center.y + crosshairSize);
    CGContextStrokePath(context);
    
    // 绘制瞄准环
    CGContextAddArc(context, center.x, center.y, crosshairSize, 0, 2 * M_PI, YES);
    CGContextStrokePath(context);
}

- (void)drawAntiRecordingModeInRect:(CGRect)rect {
    // 这是防录屏模式下的特殊绘制
    // 在这里使用特殊的绘制技术，使得肉眼可见但系统录屏无法捕获或很难捕获
    
    // 注意：这里使用的技术在实际应用中应该更加复杂，
    // 例如使用Metal渲染、修改着色器、快速闪烁等技术
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 创建特殊的图案或频率变换，肉眼可见但录屏难以捕获
    // 这里只是一个简单示例，实际应用需要更复杂的实现
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:0.01].CGColor);
    CGContextFillRect(context, self.bounds);
    
    // 你可以在这里添加更多高级的防录屏技术
    // ...
}

@end 