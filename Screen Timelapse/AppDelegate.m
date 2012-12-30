//
//  AppDelegate.m
//  Screen Timelapse
//
//  Created by TiBounise on 30/12/12.
//  Copyright (c) 2012 TiBounise. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize dockBadgeSelector;
@synthesize timelapseMenuitem;
@synthesize intervalLabel;
@synthesize sliderInterval;
@synthesize extensionMenu;
@synthesize PrefWindow;

- (void)dealloc {
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    prefs = [[NSUserDefaults standardUserDefaults] retain];
    if ([prefs objectForKey:@"PicturesFormat"] == nil) {
        [prefs setObject:@".jpg" forKey:@"PicturesFormat"];
    }
    if ([prefs objectForKey:@"Interval"] == nil) {
        [prefs setFloat:1 forKey:@"Interval"];
    }
    if ([prefs objectForKey:@"ShowBadge"] == nil) {
        [prefs setBool:YES forKey:@"ShowBadge"];
    }
    [prefs synchronize];
    [extensionMenu selectItemWithTitle:[prefs objectForKey:@"PicturesFormat"]];
    [sliderInterval setDoubleValue:[prefs floatForKey:@"Interval"]];
    [intervalLabel setStringValue:[NSString stringWithFormat:@"Actual interval : %.f secs",[sliderInterval floatValue]]];
    [dockBadgeSelector setState:[prefs boolForKey:@"ShowBadge"]];
    counter = 0;
    timer = nil;
    dockBadge = [[NSApplication sharedApplication] dockTile];
}

- (IBAction)dockBadgeSelectorAct:(id)sender {
    [prefs setBool:[dockBadgeSelector state] forKey:@"ShowBadge"];
    if ([dockBadgeSelector state] == NSOffState) {
        [dockBadge setBadgeLabel:nil];
    }
}

-(void)startTimer {
    timer = [NSTimer scheduledTimerWithTimeInterval:[prefs floatForKey:@"Interval"] target:self selector:@selector(timelapseRoutine) userInfo:nil repeats:YES];
    [timelapseMenuitem setTitle:@"Stop timelapse"];
}
-(void)stopTimer {
    [timer invalidate];
    timer = nil;
    [timelapseMenuitem setTitle:@"Launch timelapse"];
}

- (IBAction)choosePath:(id)sender {
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanCreateDirectories:YES];
    if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
        NSURL *source = [[[openDlg URLs] objectAtIndex: 0] retain];
        [prefs setObject:[source path] forKey:@"Url"];
        [prefs synchronize];
    }
}

- (IBAction)chooseExtension:(id)sender {
    [prefs setObject:[[extensionMenu selectedItem] title] forKey:@"PicturesFormat"];
    [prefs synchronize];
}

- (IBAction)slideInterval:(id)sender {
    [intervalLabel setStringValue:[NSString stringWithFormat:@"Actual interval : %.f secs",[sender floatValue]]];
    [prefs setFloat:[sender floatValue] forKey:@"Interval"];
    [prefs synchronize];
}
- (IBAction)timelapseTrigger:(id)sender {
    if (timer == nil) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}
-(void)timelapseRoutine {
    if ([prefs objectForKey:@"Url"] != nil && [[NSFileManager defaultManager] fileExistsAtPath:[prefs objectForKey:@"Url"]]) {
        NSString *format = [[prefs objectForKey:@"PicturesFormat"] substringFromIndex:1];
        NSString *url = [NSString stringWithFormat:@"%@/%d.%@",[prefs objectForKey:@"Url"],counter,format];
        NSArray *args = [NSArray arrayWithObjects:@"-C",@"-m",@"-x",url,nil];
        if (![[NSFileManager defaultManager] fileExistsAtPath:url]) {
            NSTask *captureTask = [[NSTask alloc] init];
            [captureTask setLaunchPath:@"/usr/sbin/screencapture"];
            [captureTask setArguments: args];
            [captureTask launch];
            [captureTask release];
            if ([dockBadgeSelector state] == NSOnState) {
                [dockBadge setBadgeLabel:[NSString stringWithFormat:@"%d", counter]];
            }
            counter++;
        } else {
            [self stopTimer];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Close"];
            [alert setMessageText:@"An error has occured"];
            [alert setInformativeText:@"Can't write to destination."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    } else {
        [self stopTimer];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Close"];
        [alert setMessageText:@"An error has occured"];
        [alert setInformativeText:@"The provided path is invalid. Go to the preferences and change it."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}
- (IBAction)resetTimelapse:(id)sender {
    counter = 0;
}
@end
