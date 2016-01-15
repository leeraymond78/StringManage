//
//  XToDoPreferencesWindowController.m
//  XToDo
//
//  Created by Georg Kaindl on 25/01/14.
//  Copyright (c) 2014 Plumn LLC. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "StringManage.h"
#import "ProjectSetting.h"

@interface PreferencesWindowController ()
@property (weak) IBOutlet NSTextField *dirTitleTextField;
@property (weak) IBOutlet NSTextField *tableTitleTextField;
@property (weak) IBOutlet NSTextField* directoryTextField;
@property (weak) IBOutlet NSTextField* tableNameTextField;
@property (weak) IBOutlet NSButton *saveBtn;

- (IBAction)saveAction:(id)sender;

@end

@implementation PreferencesWindowController

- (id)init
{
    return [self initWithWindowNibName:@"PreferencesWindowController"];
}

- (void)loadWindow
{
    [super loadWindow];
    
    [self.window setTitle:LocalizedString(@"Preferences")];
    [self.dirTitleTextField setStringValue:LocalizedString(@"SearchDirectory")];
    [self.tableTitleTextField setStringValue:LocalizedString(@"SearchTableName")];
    self.directoryTextField.stringValue = [[ProjectSetting shareInstance] searchDirectory];
    self.tableNameTextField.stringValue = [[ProjectSetting shareInstance] searchTableName];
    [self.saveBtn setTitle:LocalizedString(@"Save")];
}

- (IBAction)saveAction:(id)sender {
    NSString *extension = [self.tableNameTextField.stringValue pathExtension];
    if(![extension isEqualToString:@"strings"]) {
        NSAlert *alert = [[NSAlert alloc]init];
        [alert setMessageText: LocalizedString(@"FileExtensionInvalid")];
        [alert addButtonWithTitle: LocalizedString(@"OK")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return;
    }
    
    if(! [[ProjectSetting shareInstance].searchDirectory isEqualToString:self.directoryTextField.stringValue]
       || ! [[ProjectSetting shareInstance].searchTableName isEqualToString: self.tableNameTextField.stringValue]) {
        [ProjectSetting shareInstance].searchDirectory = self.directoryTextField.stringValue;
        [ProjectSetting shareInstance].searchTableName = self.tableNameTextField.stringValue;
        [[ProjectSetting shareInstance] save];
    }
}
@end