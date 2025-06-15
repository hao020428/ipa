#import "../../include/AppDelegate.h"
#import "../../include/FloatingWindow.h"
#import "../../include/AntiRecording.h"
#import "../../include/SettingsViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) FloatingWindow *floatingWindow;
@property (nonatomic, strong) AntiRecording *antiRecording;
@property (nonatomic, strong) UIViewController *rootViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 创建主窗口
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    // 设置根视图控制器
    self.rootViewController = [[SettingsViewController alloc] init];
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
    
    // 初始化悬浮窗口
    self.floatingWindow = [[FloatingWindow alloc] init];
    [self.floatingWindow show];
    
    // 初始化防录屏功能
    self.antiRecording = [[AntiRecording alloc] init];
    [self.antiRecording startAntiDetection];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 在后台继续运行
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 确保悬浮窗恢复显示
    [self.floatingWindow show];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // 保存设置
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end