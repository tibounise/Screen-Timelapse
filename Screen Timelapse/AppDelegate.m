//
//  AppDelegate.m
//  Screen Timelapse
//
//  Created by TiBounise on 30/12/12.
//  Copyright (c) 2012 TiBounise. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
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
    [prefs synchronize];
    [extensionMenu selectItemWithTitle:[prefs objectForKey:@"PicturesFormat"]];
    [sliderInterval setDoubleValue:[prefs floatForKey:@"Interval"]];
    [intervalLabel setStringValue:[NSString stringWithFormat:@"Actual interval : %.f secs",[sliderInterval floatValue]]];
    counter = 0;
    timelapseTimer = nil;
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
    if (timelapseTimer == nil) {
        timelapseTimer = [NSTimer scheduledTimerWithTimeInterval:[prefs floatForKey:@"Interval"] target:self selector:@selector(timelapseRoutine) userInfo:nil repeats:YES];
        [timelapseMenuitem setTitle:@"Stop timelapse"];
    } else {
        [timelapseTimer invalidate];
        timelapseTimer = nil;
        [timelapseMenuitem setTitle:@"Launch timelapse"];
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
            counter++;
        } else {
            [timelapseTimer invalidate];
            timelapseTimer = nil;
            [timelapseMenuitem setTitle:@"Launch timelapse"];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Close"];
            [alert setMessageText:@"An error has occured"];
            [alert setInformativeText:@"Can't write to destination."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    } else {
        [timelapseTimer invalidate];
        timelapseTimer = nil;
        [timelapseMenuitem setTitle:@"Launch timelapse"];
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
