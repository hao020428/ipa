#import "../../include/ControlPanel.h"

@interface ControlPanel ()

@property (nonatomic, strong) UISwitch *espSwitch;
@property (nonatomic, strong) UISwitch *aimbotSwitch;
@property (nonatomic, strong) UISegmentedControl *aimbotTargetSegment;
@property (nonatomic, strong) UISlider *aimbotSpeedSlider;
@property (nonatomic, strong) UISegmentedControl *styleSelector;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, copy) ESPToggleCallback espToggleCallback;
@property (nonatomic, copy) AimbotToggleCallback aimbotToggleCallback;
@property (nonatomic, copy) AimbotTargetCallback aimbotTargetCallback;
@property (nonatomic, copy) AimbotSpeedCallback aimbotSpeedCallback;

@end

@implementation ControlPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 设置面板背景
    self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:0.8].CGColor;
    
    // 添加标题标签
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 30)];
    titleLabel.text = @"游戏辅助设置";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:titleLabel];
    
    // 添加分隔线
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(15, 45, self.frame.size.width - 30, 1)];
    separatorView.backgroundColor = [UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:0.6];
    [self addSubview:separatorView];
    
    // 设置内容
    [self setupESPSection:50];
    [self setupAimbotSection:130];
    [self setupStyleSection:250];
    [self setupCloseButton];
}

- (void)setupESPSection:(CGFloat)startY {
    // ESP标题
    UILabel *espLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, startY, 150, 30)];
    espLabel.text = @"绘制透视 (ESP)";
    espLabel.textColor = [UIColor whiteColor];
    espLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:espLabel];
    
    // ESP开关
    self.espSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 65, startY, 50, 30)];
    self.espSwitch.onTintColor = [UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:1.0];
    [self.espSwitch addTarget:self action:@selector(espSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.espSwitch];
    
    // ESP描述
    UILabel *espDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, startY + 30, self.frame.size.width - 30, 40)];
    espDescLabel.text = @"显示敌人方框、血量、距离等信息";
    espDescLabel.textColor = [UIColor lightGrayColor];
    espDescLabel.font = [UIFont systemFontOfSize:12];
    espDescLabel.numberOfLines = 0;
    [self addSubview:espDescLabel];
}

- (void)setupAimbotSection:(CGFloat)startY {
    // 自瞄标题
    UILabel *aimbotLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, startY, 150, 30)];
    aimbotLabel.text = @"自动瞄准";
    aimbotLabel.textColor = [UIColor whiteColor];
    aimbotLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:aimbotLabel];
    
    // 自瞄开关
    self.aimbotSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 65, startY, 50, 30)];
    self.aimbotSwitch.onTintColor = [UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:1.0];
    [self.aimbotSwitch addTarget:self action:@selector(aimbotSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.aimbotSwitch];
    
    // 目标部位选择器
    UILabel *targetLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, startY + 40, 80, 25)];
    targetLabel.text = @"瞄准部位:";
    targetLabel.textColor = [UIColor whiteColor];
    targetLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:targetLabel];
    
    self.aimbotTargetSegment = [[UISegmentedControl alloc] initWithItems:@[@"头部", @"胸部"]];
    self.aimbotTargetSegment.frame = CGRectMake(95, startY + 40, 160, 30);
    self.aimbotTargetSegment.selectedSegmentIndex = 0;
    self.aimbotTargetSegment.backgroundColor = [UIColor darkGrayColor];
    self.aimbotTargetSegment.tintColor = [UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:1.0];
    [self.aimbotTargetSegment addTarget:self action:@selector(aimbotTargetChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.aimbotTargetSegment];
    
    // 速度调整
    UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, startY + 80, 80, 25)];
    speedLabel.text = @"瞄准速度:";
    speedLabel.textColor = [UIColor whiteColor];
    speedLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:speedLabel];
    
    self.aimbotSpeedSlider = [[UISlider alloc] initWithFrame:CGRectMake(95, startY + 80, 160, 30)];
    self.aimbotSpeedSlider.minimumValue = 0.1;
    self.aimbotSpeedSlider.maximumValue = 1.0;
    self.aimbotSpeedSlider.value = 0.5;
    self.aimbotSpeedSlider.continuous = YES;
    self.aimbotSpeedSlider.tintColor = [UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:1.0];
    [self.aimbotSpeedSlider addTarget:self action:@selector(aimbotSpeedChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.aimbotSpeedSlider];
}

- (void)setupStyleSection:(CGFloat)startY {
    // 风格标题
    UILabel *styleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, startY, 150, 30)];
    styleLabel.text = @"显示风格";
    styleLabel.textColor = [UIColor whiteColor];
    styleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:styleLabel];
    
    // 风格选择器
    self.styleSelector = [[UISegmentedControl alloc] initWithItems:@[@"简约", @"彩色", @"科技"]];
    self.styleSelector.frame = CGRectMake(15, startY + 40, self.frame.size.width - 30, 30);
    self.styleSelector.selectedSegmentIndex = 0;
    self.styleSelector.backgroundColor = [UIColor darkGrayColor];
    self.styleSelector.tintColor = [UIColor colorWithRed:0.3 green:0.6 blue:1.0 alpha:1.0];
    [self addSubview:self.styleSelector];
}

- (void)setupCloseButton {
    // 添加关闭按钮
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(self.frame.size.width - 40, 10, 25, 25);
    [self.closeButton setTitle:@"×" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
}

#pragma mark - 事件处理

- (void)espSwitchChanged:(UISwitch *)sender {
    if (self.espToggleCallback) {
        self.espToggleCallback(sender.isOn);
    }
}

- (void)aimbotSwitchChanged:(UISwitch *)sender {
    // 更新UI元素状态
    self.aimbotTargetSegment.enabled = sender.isOn;
    self.aimbotSpeedSlider.enabled = sender.isOn;
    
    if (self.aimbotToggleCallback) {
        self.aimbotToggleCallback(sender.isOn);
    }
}

- (void)aimbotTargetChanged:(UISegmentedControl *)sender {
    if (self.aimbotTargetCallback) {
        self.aimbotTargetCallback(sender.selectedSegmentIndex);
    }
}

- (void)aimbotSpeedChanged:(UISlider *)sender {
    if (self.aimbotSpeedCallback) {
        self.aimbotSpeedCallback(sender.value);
    }
}

- (void)closeButtonPressed {
    self.hidden = YES;
}

#pragma mark - 公共方法

- (void)setESPToggleCallback:(ESPToggleCallback)callback {
    self.espToggleCallback = callback;
}

- (void)setAimbotToggleCallback:(AimbotToggleCallback)callback {
    self.aimbotToggleCallback = callback;
}

- (void)setAimbotTargetCallback:(AimbotTargetCallback)callback {
    self.aimbotTargetCallback = callback;
}

- (void)setAimbotSpeedCallback:(AimbotSpeedCallback)callback {
    self.aimbotSpeedCallback = callback;
}

@end 