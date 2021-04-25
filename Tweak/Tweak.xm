#import "AmongLock.h"

BOOL enabled;

%group AmongLock

%hook CSPasscodeViewController

- (void)viewDidLoad { // add video players

	%orig;

	// add background video if use as wallpaper is disabled
	if (enableBackgroundVideoSwitch && !useAsWallpaperSwitch) {
		NSString* backgroundFilePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/background.mp4"];
		NSURL* backgroundUrl = [NSURL fileURLWithPath:backgroundFilePath];

		if (!backgroundPlayerItem) backgroundPlayerItem = [AVPlayerItem playerItemWithURL:backgroundUrl];

		if (!backgroundPlayer) backgroundPlayer = [AVQueuePlayer playerWithPlayerItem:backgroundPlayerItem];
		[backgroundPlayer setVolume:0.0];
		[backgroundPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];

		if (!backgroundPlayerLooper) backgroundPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:backgroundPlayer templateItem:backgroundPlayerItem];

		if (!backgroundPlayerLayer) backgroundPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:backgroundPlayer];
		[backgroundPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
		[backgroundPlayerLayer setFrame:[[[self view] layer] bounds]];
		[backgroundPlayerLayer setHidden:YES];

		[[[self view] layer] insertSublayer:backgroundPlayerLayer atIndex:1];
	}


	// ejection video
	if (enableEjectionVideoSwitch) {
		NSString* ejectionFilePath;
		if (isiPhone)
			ejectionFilePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/ejectioniphone.mp4"];
		else if (isiPod)
			ejectionFilePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/ejectionipod.mp4"];
		else if (isiPad)
			ejectionFilePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/ejectionipad.mp4"];
		NSURL* ejectionUrl = [NSURL fileURLWithPath:ejectionFilePath];

		if (!ejectionPlayerItem) ejectionPlayerItem = [AVPlayerItem playerItemWithURL:ejectionUrl];

		if (!ejectionPlayer) ejectionPlayer = [AVPlayer playerWithPlayerItem:ejectionPlayerItem];
		[ejectionPlayer setVolume:1.0];
		[ejectionPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];

		if (!ejectionPlayerLayer) ejectionPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:ejectionPlayer];
		[ejectionPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
		[ejectionPlayerLayer setFrame:[[[self view] layer] bounds]];
		[ejectionPlayerLayer setHidden:YES];

		[[[self view] layer] addSublayer:ejectionPlayerLayer];
	}


	if (enableBackgroundVideoSwitch || enableEjectionVideoSwitch) [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];


	// view to block passcode
	if (enableEjectionVideoSwitch) {
		viewToBlockPasscode = [[UIView alloc] initWithFrame:[[self view] bounds]];
		[viewToBlockPasscode setBackgroundColor:[UIColor clearColor]];
		[viewToBlockPasscode setHidden:YES];

		[[self view] addSubview:viewToBlockPasscode];

		if (tapToDismissEjectionSwitch) {
			UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ejectionVideoFinishedPlaying)];
			[tap setNumberOfTapsRequired:1];
			[tap setNumberOfTouchesRequired:1];
			[viewToBlockPasscode addGestureRecognizer:tap];
		}
	}
	
	if (enableEjectionVideoSwitch) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ejectionVideoFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:[ejectionPlayer currentItem]];
	if (changeFrameWhenRotatingSwitch) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutPlayerLayer:) name:@"amonglockLayoutPlayerLayer" object:nil];

}

- (void)viewWillAppear:(BOOL)animated { // start background video playback when passcode view appears and play sound

	%orig;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockHideElements" object:nil];

	if (!useAsWallpaperSwitch) {
		[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
		[backgroundPlayerLayer setHidden:NO];
		[backgroundPlayer play];
	}

	if (passcodeAppearSoundSwitch) {
		SystemSoundID sound = 0;
		AudioServicesDisposeSystemSoundID(sound);
		AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeAppeared.mp3"]), &sound);
		AudioServicesPlaySystemSound((SystemSoundID)sound);
	}

}

- (void)viewWillDisappear:(BOOL)animated { // unhide faceid lock and homebar when passcode disappears

	%orig;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockUnhideElements" object:nil];

	if (enableEjectionVideoSwitch) {
		[viewToBlockPasscode setHidden:YES];
		[ejectionPlayerLayer setHidden:YES];
		[ejectionPlayer pause];
		[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	}

}

%new
- (void)ejectionVideoFinishedPlaying { // reset buttons and hide ejection video when done playing

	[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockFailedAttemptReset" object:nil];
	if (enableEjectionVideoSwitch) {
		[viewToBlockPasscode setHidden:YES];
		[ejectionPlayerLayer setHidden:YES];
		[ejectionPlayer pause];
		[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	}

}

%new
- (void)layoutPlayerLayer:(NSNotification *)notification {

	if (![notification.name isEqual:@"amonglockLayoutPlayerLayer"]) return;
	if (enableBackgroundVideoSwitch) [backgroundPlayerLayer setFrame:[[[self view] layer] bounds]];
	if (enableEjectionVideoSwitch) [ejectionPlayerLayer setFrame:[[[self view] layer] bounds]];

}

%end

%hook CSCoverSheetViewController

- (void)viewDidLoad { // add background video if use as wallpaper is enabled

	%orig;

	if (!enableBackgroundVideoSwitch && !useAsWallpaperSwitch) return;
	NSString* backgroundFilePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/background.mp4"];
	NSURL* backgroundUrl = [NSURL fileURLWithPath:backgroundFilePath];

	if (!backgroundPlayerItem) backgroundPlayerItem = [AVPlayerItem playerItemWithURL:backgroundUrl];

	if (!backgroundPlayer) backgroundPlayer = [AVQueuePlayer playerWithPlayerItem:backgroundPlayerItem];
	[backgroundPlayer setVolume:0.0];
	[backgroundPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];

	if (!backgroundPlayerLooper) backgroundPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:backgroundPlayer templateItem:backgroundPlayerItem];

	if (!backgroundPlayerLayer) backgroundPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:backgroundPlayer];
	[backgroundPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[backgroundPlayerLayer setFrame:[[[self view] layer] bounds]];
	[backgroundPlayerLayer setHidden:YES];

	[[[self view] layer] insertSublayer:backgroundPlayerLayer atIndex:0];

	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

	if (changeFrameWhenRotatingSwitch) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutPlayerLayer:) name:@"amonglockLayoutPlayerLayer" object:nil];

}

- (void)viewWillAppear:(BOOL)animated { // play wallpaper when lockscreen appears

	%orig;

	if (enableBackgroundVideoSwitch && !useAsWallpaperSwitch) return;
	[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	[backgroundPlayerLayer setHidden:NO];
	[backgroundPlayer play];

}

- (void)viewWillDisappear:(BOOL)animated { // stop wallpaper when lockscreen disappears

	%orig;

	if (enableBackgroundVideoSwitch && !useAsWallpaperSwitch) return;
	[backgroundPlayerLayer setHidden:YES];
	[backgroundPlayer pause];
	[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

}

%new
- (void)layoutPlayerLayer:(NSNotification *)notification {

	if (![notification.name isEqual:@"amonglockLayoutPlayerLayer"]) return;
	[backgroundPlayerLayer setFrame:[[[self view] layer] bounds]];

}

%end

%hook CSPasscodeBackgroundView

- (void)didMoveToWindow { // hide passcode blur and dim if background as wallpaper is enabled

	%orig;

	if (enableBackgroundVideoSwitch && !useAsWallpaperSwitch) return;
	MTMaterialView* blurView = MSHookIvar<MTMaterialView *>(self, "_materialView");
	UIView* dimView1 = MSHookIvar<UIView *>(self, "_lightenSourceOverView");
	UIView* dimView2 = MSHookIvar<UIView *>(self, "_plusDView");

	[blurView setHidden:YES];
	[dimView1 setHidden:YES];
	[dimView2 setHidden:YES];

}

%end

%hook SBUISimpleFixedDigitPasscodeEntryField

- (void)didMoveToWindow { // add bulbs to the original passcode entry field

	%orig;

	if (!enableBulbsSwitch) return;
	[self setClipsToBounds:NO];

	NSMutableArray* indicators = MSHookIvar<NSMutableArray *>(self, "_characterIndicators");
	for (UIView* indicatorSubview in indicators) {
		UIImageView* bulb = [[UIImageView alloc] initWithFrame:[indicatorSubview bounds]];
		bulb.bounds = CGRectInset([bulb frame], 2.5, -8.5);
		[bulb setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/bulbOff.png"]];
		[indicatorSubview addSubview:bulb];
	}

}

%end

%hook SBUIPasscodeTextField

- (id)initWithFrame:(CGRect)frame { // add notification observer

    if (enableBulbsSwitch) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUnlockNotification:) name:@"amonglockUnlockedWithBiometrics" object:nil];

	return %orig;

}

- (void)setText:(NSString *)arg1 { // update bulbs when entering passcode

    %orig;

	if (!enableBulbsSwitch) return;
    if ([[self delegate] isKindOfClass:%c(SBUISimpleFixedDigitPasscodeEntryField)]) {
        NSMutableArray* indicators = [[self delegate] valueForKey:@"_characterIndicators"];
		SBUINumericPasscodeEntryFieldBase* entryBase = [self delegate];

        for (short i = 0; i < [entryBase maxNumbersAllowed]; i++) {
            UIView* view = (UIView *)[indicators objectAtIndex:i];
            for (UIImageView* imageView in [view subviews]) {
                if ([imageView isKindOfClass:%c(UIImageView)]) {
					if (i < [arg1 length])
                        [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/bulbOn.png"]];
                    else
                        [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/bulbOff.png"]];
				}
            }
        }
    }

}

%new
- (void)receiveUnlockNotification:(NSNotification *)notification { // update bulbs if authenticated with biometrics

	if (!enableBulbsSwitch) return;
	if (![notification.name isEqual:@"amonglockUnlockedWithBiometrics"]) return;
	SBUINumericPasscodeEntryFieldBase* entryBase = [self delegate];
	if ([entryBase maxNumbersAllowed] == 4)
		[self setText:@"0000"];
	else if ([entryBase maxNumbersAllowed] == 6)
		[self setText:@"000000"];

}

%end

%hook SBNumberPadWithDelegate

- (void)didMoveToWindow { // add passcode background image

	%orig;
	
	if (!themePasscodeSwitch) return;
	if (!passcodeBackground) {
		passcodeBackground = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeBackground.bounds = CGRectInset(passcodeBackground.frame, -35, -35);
		[passcodeBackground setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeBackground.png"]];
	}

	if (![passcodeBackground isDescendantOfView:self]) [self insertSubview:passcodeBackground atIndex:0];

	self.transform = CGAffineTransformMakeScale(0.85, 0.85);

}

%end

%hook SBPasscodeNumberPadButton

- (void)didMoveToWindow { // add passcode button image

	%orig;
	
	if (!themePasscodeSwitch) return;
	passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
	passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
	[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeButtonOff.png"]];

	if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];

	[self performSelector:@selector(changePasscodeButtonImages) withObject:self afterDelay:0.5];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPasscodeAttemptAnimation:) name:@"amonglockFailedAttemptAnimation" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePasscodeButtonImages) name:@"amonglockFailedAttemptReset" object:nil];

}

%new
- (void)changePasscodeButtonImages { // change passcode images to the 'on' state images

	if (!themePasscodeSwitch) return;
	passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
	passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
	[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeButtonOn.png"]];

	if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];

}

%new
- (void)failedPasscodeAttemptAnimation:(NSNotification *)notification { // passcode button animation on failed passcode

	if (!wrongPasscodeAnimationSwitch || ![notification.name isEqual:@"amonglockFailedAttemptAnimation"]) return;
	if (isBlocked || (unlockSource == 18 || unlockSource == 9)) return;
	
	passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
	passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
	[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeButtonFailed.png"]];

	if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
		[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeButtonOn.png"]];

		if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
		[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeButtonFailed.png"]];

		if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.9 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
		[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeButtonOn.png"]];

		if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
		[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeButtonOff.png"]];

		if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];
	});

	if (enableEjectionVideoSwitch) return;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockFailedAttemptReset" object:nil];
	});

}

%end

%hook TPNumberPadButton

- (void)setColor:(UIColor *)arg1 { // remove passcode button background

	if (themePasscodeSwitch)
		%orig(nil);
	else
		%orig;

}

%end

%hook SBUIPasscodeLockNumberPad

- (void)didMoveToWindow { // hide emergency call, backspace, cancel button

	%orig;

	if (hideEmergencyButtonSwitch) {
		SBUIButton* emergencyCallButton = MSHookIvar<SBUIButton *>(self, "_emergencyCallButton");
		if (hideEmergencyButtonSwitch)
			[emergencyCallButton removeFromSuperview];
	}

	if (hideCancelButtonSwitch) {
		SBUIButton* backspaceButton = MSHookIvar<SBUIButton *>(self, "_backspaceButton");
		SBUIButton* cancelButton = MSHookIvar<SBUIButton *>(self, "_cancelButton");
		if (hideCancelButtonSwitch) {
			[backspaceButton removeFromSuperview];
			[cancelButton removeFromSuperview];
		}
	}

}

%end

%hook SBLockScreenManager

- (void)attemptUnlockWithPasscode:(id)arg1 finishUIUnlock:(BOOL)arg2 completion:(id)arg3 { // show video after failed attempt, stop background video playback when passcode view disappears and play sound

	%orig;

	if ([self isUILocked]) {
		if (isBlocked || (unlockSource == 18 || unlockSource == 9)) return;
		if (wrongPasscodeAnimationSwitch) [[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockFailedAttemptAnimation" object:nil];
		if (enableEjectionVideoSwitch) [viewToBlockPasscode setHidden:NO];

		if (enableEjectionVideoSwitch) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
				[ejectionPlayerLayer setHidden:NO];
				[ejectionPlayer play];
			});
		}

		if (wrongPasscodeSoundSwitch) {
			SystemSoundID sound = 0;
			AudioServicesDisposeSystemSoundID(sound);
			AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/wrongPasscode.mp3"]), &sound);
			AudioServicesPlaySystemSound((SystemSoundID)sound);
		}	
	} else {
		isLocked = NO;
		if (enableEjectionVideoSwitch) {
			[viewToBlockPasscode setHidden:YES];
			[ejectionPlayerLayer setHidden:YES];
			[ejectionPlayer pause];
			[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
		}

		if (enableBackgroundVideoSwitch && !useAsWallpaperSwitch) {
			[backgroundPlayerLayer setHidden:YES];
			[backgroundPlayer pause];
			[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
		}

		if (passcodeDisappearSoundSwitch) {
			SystemSoundID sound = 0;
			AudioServicesDisposeSystemSoundID(sound);
			AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/passcodeDisappeared.mp3"]), &sound);
			AudioServicesPlaySystemSound((SystemSoundID)sound);
		}
	}

}

- (void)lockUIFromSource:(int)arg1 withOptions:(id)arg2 completion:(id)arg3 { // stop wallpaper when locked

    %orig;
	isLocked = YES;

	if (!useAsWallpaperSwitch) return;
	[backgroundPlayerLayer setHidden:YES];
	[backgroundPlayer pause];
	[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

}

- (BOOL)unlockUIFromSource:(int)arg1 withOptions:(id)arg2 { // get unlock source

	unlockSource = arg1;

	return %orig;

}

%end

%hook SBBacklightController

- (void)turnOnScreenFullyWithBacklightSource:(long long)arg1 { // play wallpaper when screen turned on

	%orig;

	if (!useAsWallpaperSwitch && !isLocked) return;
	[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	[backgroundPlayerLayer setHidden:NO];
	[backgroundPlayer play];

}

%end

%hook SBDashBoardBiometricUnlockController

- (void)setAuthenticated:(BOOL)arg1 { // update bulbs when authenticated with biometrics

	%orig;

	if (enableBulbsSwitch && arg1) [[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockUnlockedWithBiometrics" object:nil];

}

%end

%hook SBFUserAuthenticationController

- (BOOL)_isTemporarilyBlocked { // detect if device is temporarily blocked

	isBlocked = %orig;

	return %orig;

}

%end

%hook SBUIPasscodeLockViewBase

- (void)_sendDelegateKeypadKeyDown { // play random button sound when pressing passcode button

	%orig;

	if (!passcodeButtonSoundSwitch) return;
	SystemSoundID sound = 0;
	AudioServicesDisposeSystemSoundID(sound);
	AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:[NSString stringWithFormat:@"/Library/PreferenceBundles/AmongLockPrefs.bundle/button%d.mp3", arc4random_uniform(4)]]), &sound);
	AudioServicesPlaySystemSound((SystemSoundID)sound);

}

%end

%hook SBUIPasscodeBiometricResource

- (BOOL)hasBiometricAuthenticationCapabilityEnabled { // disable faceid animation when swiping up

	if (hideFaceIDAnimationSwitch)
		return NO;
	else
		return %orig;

}

%end

%hook SpringBoard

- (void)noteInterfaceOrientationChanged:(long long)arg1 duration:(double)arg2 logMessage:(id)arg3 {

	%orig;

	if (!changeFrameWhenRotatingSwitch) return;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockLayoutPlayerLayer" object:nil];
	});

}

%end

%hook SBUIProudLockIconView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockHideElements" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockUnhideElements" object:nil];

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // hide or unhide faceid lock

	if ([notification.name isEqual:@"amonglockHideElements"])
		[self setHidden:YES];
	else if ([notification.name isEqual:@"amonglockUnhideElements"])
		[self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook SBFLockScreenDateView

- (id)initWithFrame:(CGRect)frame { // add notification observer

	if (useAsWallpaperSwitch) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockHideElements" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockUnhideElements" object:nil];
	}

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // hide or unhide homebar

	if ([notification.name isEqual:@"amonglockHideElements"])
		[self setHidden:YES];
	else if ([notification.name isEqual:@"amonglockUnhideElements"])
		[self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook SBUIPasscodeLockViewWithKeypad

- (void)setStatusTitleView:(UILabel *)arg1 { // hide enter passcode text

	%orig(nil);

}

%end

%hook NCNotificationListView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    if (useAsWallpaperSwitch) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockHideElements" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockUnhideElements" object:nil];
	}

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // hide or unhide homebar

	if ([notification.name isEqual:@"amonglockHideElements"])
		[self setHidden:YES];
	else if ([notification.name isEqual:@"amonglockUnhideElements"])
		[self setHidden:NO];

}
  
- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSQuickActionsButton

- (id)initWithFrame:(CGRect)frame { // add notification observer

	if (useAsWallpaperSwitch) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockHideElements" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockUnhideElements" object:nil];
	}

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // hide or unhide homebar

	if ([notification.name isEqual:@"amonglockHideElements"])
		[self setHidden:YES];
	else if ([notification.name isEqual:@"amonglockUnhideElements"])
		[self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSTeachableMomentsContainerView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockHideElements" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockUnhideElements" object:nil];

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // hide or unhide homebar

	if ([notification.name isEqual:@"amonglockHideElements"])
		[self setHidden:YES];
	else if ([notification.name isEqual:@"amonglockUnhideElements"])
		[self setHidden:NO];

}
  
- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.amonglockpreferences"];

	[preferences registerBool:&enabled default:nil forKey:@"Enabled"];

	// Background Video
	[preferences registerBool:&enableBackgroundVideoSwitch default:YES forKey:@"enableBackgroundVideo"];
	[preferences registerBool:&useAsWallpaperSwitch default:NO forKey:@"useAsWallpaper"];

	// Ejection Video
	[preferences registerBool:&enableEjectionVideoSwitch default:YES forKey:@"enableEjectionVideo"];

	// Bulbs
	[preferences registerBool:&enableBulbsSwitch default:YES forKey:@"enableBulbs"];

	// Passcode
	[preferences registerBool:&themePasscodeSwitch default:YES forKey:@"themePasscode"];
	[preferences registerBool:&wrongPasscodeAnimationSwitch default:YES forKey:@"wrongPasscodeAnimation"];

	// Audio
	[preferences registerBool:&passcodeAppearSoundSwitch default:YES forKey:@"passcodeAppearSound"];
	[preferences registerBool:&passcodeDisappearSoundSwitch default:YES forKey:@"passcodeDisappearSound"];
	[preferences registerBool:&wrongPasscodeSoundSwitch default:YES forKey:@"wrongPasscodeSound"];
	[preferences registerBool:&passcodeButtonSoundSwitch default:YES forKey:@"passcodeButtonSound"];

	// Hiding
	[preferences registerBool:&hideEmergencyButtonSwitch default:NO forKey:@"hideEmergencyButton"];
	[preferences registerBool:&hideCancelButtonSwitch default:NO forKey:@"hideCancelButton"];
	[preferences registerBool:&hideFaceIDAnimationSwitch default:YES forKey:@"hideFaceIDAnimation"];

	// Miscellaneous
	[preferences registerBool:&tapToDismissEjectionSwitch default:YES forKey:@"tapToDismissEjection"];
	[preferences registerBool:&changeFrameWhenRotatingSwitch default:YES forKey:@"changeFrameWhenRotating"];

	struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

	if ([deviceModel containsString:@"iPhone"])
		isiPhone = YES;
	else if ([deviceModel containsString:@"iPod"])
		isiPod = YES;
	else if ([deviceModel containsString:@"iPad"])
		isiPad = YES;

	if (enabled) {
		%init(AmongLock);
	}

}