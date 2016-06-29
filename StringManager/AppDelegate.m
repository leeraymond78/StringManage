//
//  AppDelegate.m
//  String Manager
//
//  Created by Raymond Li on 28/6/2016.
//  Copyright © 2016 Raymond Li All rights reserved.
//

#import "AppDelegate.h"
#import "StringWindowController.h"

@interface AppDelegate () <NSMenuDelegate>

@property (nonatomic, strong) StringWindowController* windowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self chooseStringFile];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{
    [self openMainWindow:filename];
    return YES;
}

#pragma mark - NSMenuDelegate

-(void)openDocument:(id)sender{
    [self chooseStringFile];
}

-(void)preference:(id)sender{
    [self.windowController showPreferencesPanel:self];
}

#pragma mark - methods

-(void)enablePreference:(BOOL)enable{
    
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu *appMenu = [[mainMenu itemAtIndex:0] submenu];
    NSMenuItem * prefMenuItem = [appMenu itemWithTitle:@"Preferences…"];
    prefMenuItem.action = enable?@selector(preference:):nil;
}

-(void)chooseStringFile{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.message = NSLocalizedString(@"Choose the .xcodeproj file to continue", nil);
    openPanel.allowsMultipleSelection = false;
    openPanel.canChooseDirectories = false;
    openPanel.canCreateDirectories = false;
    openPanel.canChooseFiles = true;
    openPanel.allowedFileTypes = @[@"xcodeproj"];
    openPanel.level = CGShieldingWindowLevel();
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *url = openPanel.URLs.firstObject;
            [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:url];
            [self openMainWindow:url.path];
        }
    }];
}

- (void)openMainWindow:(NSString *)filePath{
    if (!self.windowController){
        self.windowController = [StringWindowController new];
        [self enablePreference:YES];
    }
    NSString *projectDir = [filePath stringByDeletingLastPathComponent];
    NSString *projectName = [filePath lastPathComponent];
    //    [self.windowController showWindow:self];
    [self.windowController.window makeKeyAndOrderFront:self];
    [self.windowController setSearchRootDir:projectDir projectName:projectName];
    [self.windowController refresh:nil];
}

@end
