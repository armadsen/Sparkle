//
//  SUStatusController.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/14/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "SUUpdater.h"

#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUVersionComparisonProtocol.h"
#import "SUStatusController.h"
#import "SUHost.h"

@interface SUStatusController ()
@property (copy) NSString *title, *buttonTitle;
@property (retain) SUHost *host;
@end

@implementation SUStatusController
@synthesize progressValue;
@synthesize maxProgressValue;
@synthesize statusText;
@synthesize title;
@synthesize buttonTitle;
@synthesize host;

- (id)initWithHost:(SUHost *)aHost
{
	self = [super initWithHost:aHost windowNibName:@"SUStatus"];
	if (self)
	{
		self.host = aHost;
		[self setShouldCascadeWindows:NO];
	}
	return self;
}

- (void)dealloc
{
	self.host = nil;
	self.title = nil;
	self.statusText = nil;
	self.buttonTitle = nil;
	[super dealloc];
}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@, %@>", [self class], [host bundlePath], [host installationPath]]; }

- (void)awakeFromNib
{
    if ([host isBackgroundApplication]) {
        [[self window] setLevel:NSFloatingWindowLevel];
    }
    
	[[self window] center];
	[[self window] setFrameAutosaveName:@"SUStatusFrame"];
	[progressBar setUsesThreadedAnimation:YES];
}

- (NSString *)windowTitle
{
	return [NSString stringWithFormat:SULocalizedString(@"Updating %@", nil), [host name]];
}

- (NSImage *)applicationIcon
{
	return [host icon];
}

- (void)beginActionWithTitle:(NSString *)aTitle maxProgressValue:(double)aMaxProgressValue statusText:(NSString *)aStatusText
{
	self.title = aTitle;
	
	self.maxProgressValue = aMaxProgressValue;
	self.statusText = aStatusText;
}

- (void)setButtonTitle:(NSString *)aButtonTitle target:(id)target action:(SEL)action isDefault:(BOOL)isDefault
{
	self.buttonTitle = aButtonTitle;
	
	[[self window] self];
	[actionButton sizeToFit];
	// Except we're going to add 15 px for padding.
	[actionButton setFrameSize:NSMakeSize([actionButton frame].size.width + 15, [actionButton frame].size.height)];
	// Now we have to move it over so that it's always 15px from the side of the window.
	[actionButton setFrameOrigin:NSMakePoint([[self window] frame].size.width - 15 - [actionButton frame].size.width, [actionButton frame].origin.y)];	
	// Redisplay superview to clean up artifacts
	[[actionButton superview] display];
	
	[actionButton setTarget:target];
	[actionButton setAction:action];
	[actionButton setKeyEquivalent:isDefault ? @"\r" : @""];
	
	// 06/05/2008 Alex: Avoid a crash when cancelling during the extraction
	[self setButtonEnabled: (target != nil)];
}

- (BOOL)progressBarShouldAnimate
{
	return YES;
}

- (void)setButtonEnabled:(BOOL)enabled
{
	[actionButton setEnabled:enabled];
}

- (BOOL)isButtonEnabled
{
	return [actionButton isEnabled];
}

- (void)setMaxProgressValue:(double)value
{
	if (value < 0.0) value = 0.0;
	maxProgressValue = value;
	[self setProgressValue:0.0];
	[progressBar setIndeterminate:(value == 0.0)];
	[progressBar startAnimation:self];
	[progressBar setUsesThreadedAnimation: YES];
}

@end
