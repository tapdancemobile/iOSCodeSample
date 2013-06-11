#import "TTTLog.h"
#import "NSObject+TTTBlocks.h"
#import "RegularTheme.h"

#define AttributeTextAlignment @"AttributeTextAlignment"
#define AttributeLineBreakMode @"AttributeLineBreakMode"
#define AttributeBackgroundColor @"AttributeBackgroundColor"
#define AttributeTextStyle @"AttributeTextStyle"
#define AttributeBackgroundImage @"AttributeBackgroundImage"
#define AttributeTitleEdgeInsets @"AttributeTitleEdgeInsets"
#define AttributeContentHorizontalAlignment @"AttributeContentHorizontalAlignment"
#define AttributeTitleColor @"AttributeTitleColor"
#define AttributeNumberOfLines @"AttributeNumberOfLines"

@implementation UIFont (RegularTheme)

+ (UIFont *)safeFontWithName:(NSString *)fontName fontSize:(CGFloat)fontSize
{
	UIFont *font = [self fontWithName:fontName size:fontSize];
	if (font == nil)
	{
		ELog(@"FontName `%@` not found", fontName);
		font = [self systemFontOfSize:fontSize];
	}
	return font;
}

+ (UIFont *)BoldFontWithSize:(CGFloat)fontSize
{
	return [self safeFontWithName:@"Helvetica-Bold" fontSize:fontSize];
}

+ (UIFont *)RegularFontWithSize:(CGFloat)fontSize
{
	return [self safeFontWithName:@"Helvetica" fontSize:fontSize];
}

@end

@implementation RegularTheme

- (id)init
{
    self = [super init];
    
    if (self)
    {
		/*
		// Add custom appearance selectors here, like:
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Solid-green.png"] forBarMetrics:UIBarMetricsDefault];

        NSDictionary* attrs = @{
            UITextAttributeTextShadowColor: [UIColor clearColor],
            UITextAttributeFont: [UIFont BoldFontWithSize:18.0]
        };
        
        [[UINavigationBar appearance] setTitleTextAttributes:attrs];
		*/
    }
    
    return self;
}

- (NSDictionary *)attributesForTextStyle:(TextStyle)style forControlState:(UIControlState)controlState
{
	NSMutableDictionary *attributes = [@{
			// An NSValue instance wrapping a UIOffset struct is expected.
			UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetZero],
			// Default is centered text, overwrite where a different alignment is needed
			AttributeTextAlignment : @(NSTextAlignmentLeft),
	} mutableCopy];

	switch (style)
	{
		default:
			WLog(@"Undetermined style %i - falling back to TextStylePlain", style);
		case TextStylePlain:
			attributes[UITextAttributeFont] = [UIFont boldSystemFontOfSize:16];
			attributes[UITextAttributeTextColor] = [UIColor colorWithWhite:0.1 alpha:1];
			attributes[AttributeLineBreakMode] = @(UILineBreakModeWordWrap);
			attributes[AttributeTextAlignment] = @(UITextAlignmentLeft);
			attributes[AttributeNumberOfLines] = @(0);
			break;
	}

	return attributes;
}

- (NSDictionary *)attributesForButtonStyle:(ButtonStyle)style withControlState:(UIControlState)controlState
{
	NSMutableDictionary *attributes = [@{
			AttributeBackgroundColor : [UIColor clearColor],
			AttributeTextStyle : @(TextStylePlain),
	} mutableCopy];

	switch (style)
	{
		default:
			WLog(@"Undetermined style %i - falling back to ButtonStylePlain", style);
		case ButtonStylePlain:
			attributes[AttributeTextStyle] = @(TextStylePlain);
			// Example image background for different control states:
			// - attributes[AttributeBackgroundImage] = (controlState & UIControlStateHighlighted) ? [[UIImage imageNamed:@"StretchingYesNoBackground-2-0-highlight"] stretchableImageWithLeftCapWidth:2 topCapHeight:0] : [[UIImage imageNamed:@"StretchingYesNoBackground-2-0"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
			attributes[AttributeTitleEdgeInsets] = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
			attributes[AttributeContentHorizontalAlignment] = @(UIControlContentHorizontalAlignmentLeft);
			attributes[AttributeTitleColor] = [UIColor grayColor];
			break;
	}

	return attributes;
}

- (void)applyTextStyle:(TextStyle)style toLabel:(UILabel *)label
{
	[self applyTextStyle:style toLabel:label forControlState:UIControlStateNormal];
}

- (void)applyTextStyle:(TextStyle)style toLabel:(UILabel *)label forControlState:(UIControlState)controlState
{
	label.backgroundColor = [UIColor clearColor];
	label.opaque = NO;

	NSDictionary *attributes = [self attributesForTextStyle:style forControlState:controlState];

	[attributes tttForKey:UITextAttributeFont performBlock:^(id value) {label.font = value;}];
	[attributes tttForKey:UITextAttributeTextColor performBlock:^(id value) {label.textColor = value;}];
	[attributes tttForKey:UITextAttributeTextShadowColor performBlock:^(id value) {label.shadowColor = value;}];
	[attributes tttForKey:UITextAttributeTextShadowOffset performBlock:^(id value) {label.shadowOffset = [self UIOffsetValueToCGSize:value];}];
	[attributes tttForKey:AttributeTextAlignment performBlock:^(id value) {label.textAlignment = [value integerValue];}];
	[attributes tttForKey:AttributeLineBreakMode performBlock:^(id value) {
		label.lineBreakMode = [value integerValue];
		label.numberOfLines = 0;
	}];
	[attributes tttForKey:AttributeNumberOfLines performBlock:^(id value) {label.numberOfLines = [value integerValue];}];
}

- (void)applyTextStyle:(TextStyle)style toTextField:(UITextField *)textField
{
	NSDictionary *attributes = [self attributesForTextStyle:style forControlState:UIControlStateNormal];

	[attributes tttForKey:UITextAttributeFont performBlock:^(id value) {textField.font = value;}];
	[attributes tttForKey:UITextAttributeTextColor performBlock:^(id value) {textField.textColor = value;}];
	[attributes tttForKey:AttributeTextAlignment performBlock:^(id value) {textField.textAlignment = [value integerValue];}];
}

- (void)applyButtonStyle:(ButtonStyle)style toButton:(UIButton *)button
{
	NSArray *controlStates = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected), @(UIControlStateDisabled)];

	for (NSNumber *controlStateNumber in controlStates)
	{
		NSInteger controlState = [controlStateNumber integerValue];
		NSDictionary *buttonAttributes = [self attributesForButtonStyle:style withControlState:controlState];

		[buttonAttributes tttForKey:AttributeTextStyle performBlock:^(id value) {[self applyTextStyle:[value integerValue] toLabel:button.titleLabel forControlState:controlState];}];
		[buttonAttributes tttForKey:AttributeBackgroundImage performBlock:^(id value) {[button setBackgroundImage:value forState:controlState];}];
		[buttonAttributes tttForKey:AttributeTitleColor performBlock:^(id value) {[button setTitleColor:value forState:controlState];}];

		if (controlState == UIControlStateNormal)
		{
			[buttonAttributes tttForKey:AttributeBackgroundColor performBlock:^(id value) {button.backgroundColor = value;}];
			[buttonAttributes tttForKey:AttributeTitleEdgeInsets performBlock:^(id value) {[button setTitleEdgeInsets:[value UIEdgeInsetsValue]];}];
			[buttonAttributes tttForKey:AttributeContentHorizontalAlignment performBlock:^(id value) {[button setContentHorizontalAlignment:[value integerValue]];}];
		}
	}
}

@end