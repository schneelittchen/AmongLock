#import "ALKContributorsSubPrefsListController.h"

UIBlurEffect* blur;
UIVisualEffectView* blurView;

@implementation ALKContributorsSubPrefsListController

- (instancetype)init {

    self = [super init];

    if (self) {
        ALKAppearanceSettings* appearanceSettings = [[ALKAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;

}

- (id)specifiers {

    return _specifiers;

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [blurView setFrame:[[self view] bounds]];
    [blurView setAlpha:1.0];
    [[self view] addSubview:blurView];

    [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [blurView setAlpha:0.0];
    } completion:nil];

}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {

    NSString *sub = [specifier propertyForKey:@"ALKSub"];
    NSString *title = [specifier name];

    _specifiers = [[self loadSpecifiersFromPlistName:sub target:self] retain];

    [self setTitle:title];
    [self.navigationItem setTitle:title];

}

- (void)setSpecifier:(PSSpecifier *)specifier {

    [self loadFromSpecifier:specifier];
    [super setSpecifier:specifier];

}

- (bool)shouldReloadSpecifiersOnResume {

    return false;

}

@end