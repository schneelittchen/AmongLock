#import "KRTableCell.h"

@interface KRLinkCell : KRTableCell

@property (nonatomic, readonly) BOOL isBig;

@property (nonatomic, retain, readonly) UIView *avatarView;

@property (nonatomic, retain, readonly) UIImageView *avatarImageView;

@property (nonatomic, retain) UIImage *avatarImage;

@end