
//
// KRTwitterCell.m
// Twitter cell that locally loads pfps 
//		based on Cephei Framework
//
// Apache 2.0 License for code used in KRPrefsLicense located in preference bundle
//


#import "KRTwitterCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>
#import <Foundation/Foundation.h>

@interface KRLinkCell ()

- (BOOL)shouldShowAvatar;

@end

@interface KRTwitterCell () {
	NSString *_user;
}

@end

@implementation KRTwitterCell

+ (NSString *)_urlForUsername:(NSString *)user {

	user = [user stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"aphelion://"]]) {
		return [@"aphelion://profile/" stringByAppendingString:user];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
		return [@"tweetbot:///user_profile/" stringByAppendingString:user];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) {
		return [@"twitterrific:///profile?screen_name=" stringByAppendingString:user];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings://"]]) {
		return [@"tweetings:///user?screen_name=" stringByAppendingString:user];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
		return [@"twitter://user?screen_name=" stringByAppendingString:user];
	} else {
		return [@"https://mobile.twitter.com/" stringByAppendingString:user];
	}
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier 
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		UIImageView *imageView = (UIImageView *)self.accessoryView;
		imageView.image = nil;//[UIImage imageNamed:@"twitter" inBundle:globalBundle];
		[imageView sizeToFit];

		_user = [specifier.properties[@"accountName"] copy];
		NSAssert(_user, @"User name not provided");

		specifier.properties[@"url"] = [self.class _urlForUsername:_user];

		self.detailTextLabel.text = [@"@" stringByAppendingString:_user];

		[self setCellEnabled:YES];

		[self loadAvatarIfNeeded];
	}

	return self;
}

- (void)setSelected:(BOOL)arg1 animated:(BOOL)arg2
{
	[super setSelected:arg1 animated:arg2];

	if (!arg1) return;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.class _urlForUsername:_user]] options:@{} completionHandler:nil];
}

#pragma mark - Avatar

- (BOOL)shouldShowAvatar {
	// HBLinkTableCell doesn’t want avatars by default, but we do. override its check method so that
	// if showAvatar is unset, we return YES
	return YES;
}

- (void)loadAvatarIfNeeded {
	if (!_user) {
		return;
	}

	if (self.avatarImage) {
		return;
	}
	// TODO: fix this
	//self.avatarImage = [UIImage imageNamed:[NSString stringWithFormat:@"/Library/PreferenceBundles/SignePrefs.bundle/%@.png", _user]];
	
	dispatch_async(dispatch_get_global_queue(0,0), ^{
		NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@/profile_image?size=original", _user]]];
		if ( data == nil )
			return;
		dispatch_async(dispatch_get_main_queue(), ^{
			self.avatarImage = [UIImage imageWithData: data];
		});
	});
}

@end