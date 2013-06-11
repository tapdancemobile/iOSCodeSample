#import "Theme.h"

static id <Theme> _currentTheme;

@implementation Theme

+ (id <Theme>)currentTheme
{
	NSAssert(_currentTheme != nil, @"Use `setCurrentTheme` before accessing `currentTheme`");
	return _currentTheme;
}

+ (void)setCurrentTheme:(id <Theme>)theme
{
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{_currentTheme = theme;});
}

- (CGSize)UIOffsetValueToCGSize:(NSValue *)offsetValue
{
	if (offsetValue == nil)
	{
		return CGSizeZero;
	}

	UIOffset offset = offsetValue ? [offsetValue UIOffsetValue] : UIOffsetZero;
	return CGSizeMake(offset.horizontal, offset.vertical);
}

@end

@implementation NSDictionary (Theme)

- (void)forAttribute:(id)attribute performBlock:(void (^)(id value))block
{
	if (self[attribute])
	{
		block(self[attribute]);
	}
}

@end