#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <sys/utsname.h>
#import <Cephei/HBPreferences.h>

HBPreferences* preferences;

extern BOOL enabled;

BOOL isLocked;
BOOL isBlocked = NO;
int unlockSource;
BOOL isiPhone = NO;
BOOL isiPod = NO;
BOOL isiPad = NO;

AVQueuePlayer* backgroundPlayer;
AVPlayerLooper* backgroundPlayerLooper;
AVPlayerItem* backgroundPlayerItem;
AVPlayerLayer* backgroundPlayerLayer;

AVPlayer* ejectionPlayer;
AVPlayerItem* ejectionPlayerItem;
AVPlayerLayer* ejectionPlayerLayer;

UIView* viewToBlockPasscode;

UIImageView* passcodeBackground;
UIImageView* passcodeButton;

UIImageView* emergencyButtonImage;
UIImageView* backspaceButtonImage;
UIImageView* cancelButtonImage;

// background video
BOOL enableBackgroundVideoSwitch = YES;
BOOL useAsWallpaperSwitch = NO;

// ejection video
BOOL enableEjectionVideoSwitch = YES;

// bulbs
BOOL enableBulbsSwitch = YES;

// passcode
BOOL themePasscodeSwitch = YES;
BOOL wrongPasscodeAnimationSwitch = YES;

// audio
BOOL passcodeAppearSoundSwitch = YES;
BOOL passcodeDisappearSoundSwitch = YES;
BOOL wrongPasscodeSoundSwitch = YES;
BOOL passcodeButtonSoundSwitch = YES;

// hiding
BOOL hideEmergencyButtonSwitch = NO;
BOOL hideCancelButtonSwitch = NO;
BOOL hideFaceIDAnimationSwitch = YES;

// miscellaneous
BOOL tapToDismissEjectionSwitch = YES;
BOOL changeFrameWhenRotatingSwitch = YES;

@interface CSPasscodeViewController : UIViewController
- (void)ejectionVideoFinishedPlaying;
- (void)layoutPlayerLayer:(NSNotification *)notification;
@end

@interface CSCoverSheetViewController : UIViewController
- (void)layoutPlayerLayer:(NSNotification *)notification;
@end

@interface MTMaterialView : UIView
@end

@interface SBUISimpleFixedDigitPasscodeEntryField : UIView
@end

@interface SBUINumericPasscodeEntryFieldBase : UIView
@property(assign, nonatomic)unsigned long long maxNumbersAllowed;
@end

@interface SBUIPasscodeTextField : UIView
@property(assign, nonatomic)id delegate;
- (void)setText:(NSString *)arg1;
@end

@interface SBNumberPadWithDelegate : UIControl
@end

@interface SBPasscodeNumberPadButton : UIControl
- (void)changePasscodeButtonImages;
- (void)failedPasscodeAttemptAnimation:(NSNotification *)notification;
@end

@interface TPNumberPadButton : UIControl
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (BOOL)isUILocked;
@end

@interface SBUIProudLockIconView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface SBFLockScreenDateView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface NCNotificationListView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface CSQuickActionsButton : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface CSTeachableMomentsContainerView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface SBUIButton : UIButton
@end

@interface XENHWidgetLayerContainerView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end