#import "../../include/SettingsViewController.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *settings;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化设置数据
    [self setupSettings];
    
    // 设置UI
    [self setupUI];
}

- (void)setupSettings {
    // 从用户默认设置中加载或使用默认值
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 如果是首次运行，设置默认值
    if (![defaults objectForKey:@"app_settings"]) {
        NSDictionary *defaultSettings = @{
            @"esp_enabled": @NO,
            @"esp_style": @0,
            @"show_health": @YES,
            @"show_distance": @YES,
            @"show_name": @YES,
            @"aimbot_enabled": @NO,
            @"aimbot_target": @0,
            @"aimbot_speed": @0.5,
            @"auto_hide": @YES,
            @"opacity": @0.8
        };
        
        [defaults setObject:defaultSettings forKey:@"app_settings"];
        [defaults synchronize];
    }
    
    // 读取设置
    self.settings = [defaults objectForKey:@"app_settings"];
    
    // 定义设置分组
    self.sections = @[
        @{
            @"title": @"绘制设置",
            @"items": @[
                @{@"key": @"esp_enabled", @"title": @"启用透视", @"type": @"switch"},
                @{@"key": @"esp_style", @"title": @"绘制风格", @"type": @"segment", @"options": @[@"简约", @"彩色", @"科技"]},
                @{@"key": @"show_health", @"title": @"显示血量", @"type": @"switch"},
                @{@"key": @"show_distance", @"title": @"显示距离", @"type": @"switch"},
                @{@"key": @"show_name", @"title": @"显示名称", @"type": @"switch"}
            ]
        },
        @{
            @"title": @"自瞄设置",
            @"items": @[
                @{@"key": @"aimbot_enabled", @"title": @"启用自瞄", @"type": @"switch"},
                @{@"key": @"aimbot_target", @"title": @"瞄准部位", @"type": @"segment", @"options": @[@"头部", @"胸部"]},
                @{@"key": @"aimbot_speed", @"title": @"瞄准速度", @"type": @"slider", @"min": @0.1, @"max": @1.0}
            ]
        },
        @{
            @"title": @"悬浮窗设置",
            @"items": @[
                @{@"key": @"auto_hide", @"title": @"游戏中自动隐藏", @"type": @"switch"},
                @{@"key": @"opacity", @"title": @"透明度", @"type": @"slider", @"min": @0.3, @"max": @1.0}
            ]
        }
    ];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    
    // 创建一个导航栏样式的视图
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    [self.view addSubview:navBar];
    
    // 添加标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    titleLabel.text = @"浮窗助手";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [navBar addSubview:titleLabel];
    
    // 创建表格视图
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
    [self.view addSubview:self.tableView];
    
    // 设置表格视图分割线样式
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionData = self.sections[section];
    NSArray *items = sectionData[@"items"];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 移除所有子视图以防复用问题
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    // 获取当前项的设置数据
    NSDictionary *sectionData = self.sections[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    NSString *key = item[@"key"];
    NSString *title = item[@"title"];
    NSString *type = item[@"type"];
    
    // 设置标题
    cell.textLabel.text = title;
    
    // 根据控件类型创建不同的UI
    if ([type isEqualToString:@"switch"]) {
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchControl.on = [self.settings[key] boolValue];
        switchControl.tag = indexPath.section * 100 + indexPath.row;
        [switchControl addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchControl;
    }
    else if ([type isEqualToString:@"segment"]) {
        NSArray *options = item[@"options"];
        UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:options];
        segmentControl.frame = CGRectMake(0, 0, 150, 30);
        segmentControl.selectedSegmentIndex = [self.settings[key] integerValue];
        segmentControl.tag = indexPath.section * 100 + indexPath.row;
        [segmentControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        [containerView addSubview:segmentControl];
        cell.accessoryView = containerView;
    }
    else if ([type isEqualToString:@"slider"]) {
        UISlider *sliderControl = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        sliderControl.minimumValue = [item[@"min"] floatValue];
        sliderControl.maximumValue = [item[@"max"] floatValue];
        sliderControl.value = [self.settings[key] floatValue];
        sliderControl.tag = indexPath.section * 100 + indexPath.row;
        [sliderControl addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        [containerView addSubview:sliderControl];
        cell.accessoryView = containerView;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionData = self.sections[section];
    return sectionData[@"title"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 事件处理

- (void)switchValueChanged:(UISwitch *)sender {
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    NSDictionary *sectionData = self.sections[section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[row];
    NSString *key = item[@"key"];
    
    // 更新设置
    NSMutableDictionary *updatedSettings = [NSMutableDictionary dictionaryWithDictionary:self.settings];
    updatedSettings[key] = @(sender.isOn);
    self.settings = updatedSettings;
    
    // 保存设置
    [self saveSettings];
}

- (void)segmentValueChanged:(UISegmentedControl *)sender {
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    NSDictionary *sectionData = self.sections[section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[row];
    NSString *key = item[@"key"];
    
    // 更新设置
    NSMutableDictionary *updatedSettings = [NSMutableDictionary dictionaryWithDictionary:self.settings];
    updatedSettings[key] = @(sender.selectedSegmentIndex);
    self.settings = updatedSettings;
    
    // 保存设置
    [self saveSettings];
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    NSDictionary *sectionData = self.sections[section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[row];
    NSString *key = item[@"key"];
    
    // 更新设置
    NSMutableDictionary *updatedSettings = [NSMutableDictionary dictionaryWithDictionary:self.settings];
    updatedSettings[key] = @(sender.value);
    self.settings = updatedSettings;
    
    // 保存设置
    [self saveSettings];
}

- (void)saveSettings {
    // 保存设置到用户默认
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.settings forKey:@"app_settings"];
    [defaults synchronize];
    
    // 发送通知，让其他组件可以更新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingsDidChange" object:nil userInfo:self.settings];
}

@end 