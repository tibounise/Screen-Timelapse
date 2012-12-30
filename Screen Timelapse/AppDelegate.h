//
//  AppDelegate.h
//  Screen Timelapse
//
//  Created by TiBounise on 30/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSUserDefaults *prefs;
    NSTimer *timer;
    NSDockTile *dockBadge;
    int counter;
}

@property (assign) IBOutlet NSPanel *PrefWindow;
- (IBAction)choosePath:(id)sender;
- (IBAction)chooseExtension:(id)sender;
@property (assign) IBOutlet NSPopUpButton *extensionMenu;
- (IBAction)slideInterval:(id)sender;
@property (assign) IBOutlet NSTextField *intervalLabel;
@property (assign) IBOutlet NSSlider *sliderInterval;
- (IBAction)timelapseTrigger:(id)sender;
@property (assign) IBOutlet NSMenuItem *timelapseMenuitem;
- (IBAction)resetTimelapse:(id)sender;
@property (assign) IBOutlet NSButton *dockBadgeSelector;
- (IBAction)dockBadgeSelectorAct:(id)sender;

-(void)startTimer;
-(void)stopTimer;

@end