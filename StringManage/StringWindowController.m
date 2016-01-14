//
//  StringWindowController.m
//  StringManage
//
//  Created by kiwik on 1/13/16.
//  Copyright © 2016 Kiwik. All rights reserved.
//

#import "StringWindowController.h"
#import "StringModel.h"
#import "StringManage.h"

#define KEY @"key"
#define REMOVE @"remove"

@interface StringWindowController()<NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate>

@property (nonatomic, strong)IBOutlet NSTableView *tableview;
@property (weak) IBOutlet NSButton *saveBtn;
@property (nonatomic, strong) NSMutableArray *stringArray;
@property (nonatomic, strong) NSMutableArray *keyArray;
@property (nonatomic, strong) NSMutableArray *actionArray;

- (IBAction)addAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end

@implementation StringWindowController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.window.level = NSFloatingWindowLevel;
    self.window.hidesOnDeactivate = YES;
    
    float width = self.tableview.bounds.size.width;
    float columnWidth = (width - 80.0)/(_stringArray.count+1);
    
    NSTableColumn *column0 = [self.tableview tableColumnWithIdentifier:@"defaultCell"];
    [self.tableview removeTableColumn:column0];
    
    NSTableColumn * column1 = [[NSTableColumn alloc] initWithIdentifier:KEY];
    [column1 setTitle:KEY];
    [column1 setWidth:columnWidth];
    [self.tableview addTableColumn:column1];
    
    for (StringModel *model in _stringArray) {
        NSTableColumn * column = [[NSTableColumn alloc] initWithIdentifier:model.identifier];
        [column setTitle:model.identifier];
        [column setWidth:columnWidth];
        [self.tableview addTableColumn:column];
    }
    
    NSTableColumn * lastcolumn = [[NSTableColumn alloc] initWithIdentifier:REMOVE];
    [lastcolumn setTitle:@""];
    [lastcolumn setWidth:80];
    [self.tableview addTableColumn:lastcolumn];
    
    self.tableview.delegate=self;
    self.tableview.dataSource = self;
    self.tableview.doubleAction = @selector(doubleClicked:);
    [self.window makeFirstResponder:self.tableview];
    
    [self.saveBtn setTitle:LocalizedString(@"Save")];
    
    [self.tableview reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditingAction:) name:NSControlTextDidEndEditingNotification object:nil];
    
    self.actionArray=[[NSMutableArray alloc]init];
}

- (IBAction)openAbout:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.xulongwu.com"]];
}

- (IBAction)showPreferencesPanel:(id)sender
{
//    [self.prefsController loadWindow];
//    
//    NSRect windowFrame = [[self window] frame], prefsFrame = [[self.prefsController window] frame];
//    prefsFrame.origin = NSMakePoint(windowFrame.origin.x + (windowFrame.size.width - prefsFrame.size.width) / 2.0,
//                                    NSMaxY(windowFrame) - NSHeight(prefsFrame) - 20.0);
//    
//    [[self.prefsController window] setFrame:prefsFrame
//                                    display:NO];
//    
//    [self.prefsController showWindow:sender];
}

- (IBAction)refresh:(id)sender
{
    [_stringArray removeAllObjects];
    [_keyArray removeAllObjects];
    
    NSMutableSet *keySet = [[NSMutableSet alloc]init];
    for (NSString *path in _pathArray) {
        StringModel *model = [[StringModel alloc]initWithPath:path];
        [_stringArray addObject:model];
        NSArray *keys = model.stringDictionary.allKeys;
        NSSet *set = [NSSet setWithArray:keys];
        [keySet unionSet:set];
    }
    
    [_keyArray addObjectsFromArray:keySet.allObjects];
    
    [self.tableview reloadData];
}

- (IBAction)addAction:(id)sender
{
    NSAlert *alert = [[NSAlert alloc]init];
    [alert setMessageText: LocalizedString(@"InputKeyMsg")];
    [alert addButtonWithTitle: LocalizedString(@"OK")];
    [alert addButtonWithTitle:LocalizedString(@"Cancel")];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [alert setAccessoryView:input];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn)
        {
            [input validateEditing];
            
            if(input.stringValue.length==0)
                return;
            
            [_keyArray addObject:input.stringValue];
            [self.tableview reloadData];
        }
    }];
}

- (IBAction)saveAction:(id)sender {
    if(_actionArray.count==0)
        return;
    
    for (StringModel *model in _stringArray)
    {
        [model doAction:_actionArray];
    }
    [_actionArray removeAllObjects];
    
    [self refresh:nil];
}

-(void)doubleClicked:(id)sender
{
    [_tableview editColumn:_tableview.clickedColumn row:_tableview.clickedRow withEvent:nil select:YES];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return NO;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn
{
    return !([tableColumn.identifier isEqualToString:KEY] || [tableColumn.identifier isEqualToString:REMOVE]);
}

-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return ![tableColumn.identifier isEqualToString:REMOVE];
}

-(void)setPathArray:(NSArray *)pathArray
{
    NSLog(@"%s",__func__);
    _pathArray = pathArray;
    if(!_stringArray)
    {
        _stringArray = [[NSMutableArray alloc]init];
    }
    
    if(!_keyArray)
    {
        _keyArray = [[NSMutableArray alloc]init];
    }
    
    [self refresh:nil];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _keyArray.count;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20.0;
}

//View based
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier=[tableColumn identifier];
    NSString *key = _keyArray[row];
    if([identifier isEqualToString:@"remove"]){
        NSButton *aView = [tableView makeViewWithIdentifier:identifier owner:self];
        if(!aView)
        {
            aView = [[NSButton alloc]initWithFrame:NSZeroRect];
            [aView setTitle:LocalizedString(@"Remove")];
            [aView setAction:@selector(removeAction:)];
            [aView setTarget:self];
            [aView setState:1];
        }
        [aView setTag:row];
        return aView;
    } else {
        NSString *title = [self titleWithKey:key identifier:identifier];
        NSTextField *aView = [tableView makeViewWithIdentifier:identifier owner:self];
        if(!aView)
        {
            aView = [[NSTextField alloc]initWithFrame:NSZeroRect];
            [aView setTextColor:[NSColor blackColor]];
            [aView setTarget:self];
        }
        [aView setTag:row];
        [aView setIdentifier:identifier];
        [aView setPlaceholderString:title];
        [aView setStringValue:title];
        return aView;
    }
}

-(void)endEditingAction:(NSNotification*)notification
{
    NSTextField *textField = notification.object;
    NSLog(@"%s %ld %@",__func__,textField.tag,textField.identifier);
    NSString *key = _keyArray[textField.tag];
    NSString *identifier = textField.identifier;
    NSString *oldValue = [self titleWithKey:key identifier:identifier];
    NSString *newValue = textField.stringValue;
    if([oldValue isEqualToString:newValue])
        return;
    
    if([identifier isEqualToString:KEY])
    {
        if([_keyArray containsObject:newValue] || newValue.length==0)
        {
            //TODO ??? key必须唯一
            [self.tableview reloadData];
        }
        else
        {
            for (StringModel *model in _stringArray)
            {
                NSString *value = [self titleWithKey:key identifier:model.identifier];
                ActionModel *action = [[ActionModel alloc]init];
                action.actionType = ActionTypeAdd;
                action.identifier = model.identifier;
                action.key = newValue;
                action.value = value;
                [_actionArray addObject:action];
                [model.stringDictionary setObject:value forKey:newValue];
                
                ActionModel *action1 = [[ActionModel alloc]init];
                action1.actionType = ActionTypeRemove;
                action1.identifier = model.identifier;
                action1.key = oldValue;
                action1.value = value;
                [_actionArray addObject:action1];
                [model.stringDictionary removeObjectForKey:key];
            }
            [_keyArray replaceObjectAtIndex:textField.tag withObject:newValue];
        }
    }
    else
    {
        for (StringModel *model in _stringArray)
        {
            if([model.identifier isEqualToString:identifier])
            {
                ActionModel *action = [[ActionModel alloc]init];
                action.actionType = ActionTypeAdd;
                action.identifier = model.identifier;
                action.key = key;
                action.value = newValue;
                [_actionArray addObject:action];
                
                [model.stringDictionary setObject:newValue forKey:key];
            }
        }
    }
}

-(void)removeAction:(id)sender
{
    NSButton *button = (NSButton*)sender;
    NSInteger row = button.tag;
    NSString *key=[_keyArray objectAtIndex:row];
    NSString *msg = [NSString stringWithFormat:LocalizedString(@"RemoveConfirm"),key];
    
    NSAlert *alert = [[NSAlert alloc]init];
    [alert setMessageText: msg];
    [alert addButtonWithTitle: LocalizedString(@"OK")];
    [alert addButtonWithTitle:LocalizedString(@"Cancel")];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn)
        {
            for (StringModel *model in _stringArray)
            {
                ActionModel *action = [[ActionModel alloc]init];
                action.actionType = ActionTypeRemove;
                action.identifier = model.identifier;
                action.key = key;
                [_actionArray addObject:action];
                
                [model.stringDictionary removeObjectForKey:key];
            }
            [_keyArray removeObjectAtIndex:row];
            
            [self.tableview beginUpdates];
            [self.tableview removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
            [self.tableview endUpdates];
            
            [self.tableview reloadData];
        }
    }];
}

-(NSString*)titleWithKey:(NSString*)key identifier:(NSString*)identifier
{
    if([identifier isEqualToString:KEY])
    {
        return key;
    }
    else
    {
        for (StringModel *model in _stringArray)
        {
            if ([identifier isEqualToString:model.identifier])
            {
                NSString *result = model.stringDictionary[key];
                return result.length ? result : @"";
            }
        }
    }
    return @"";
}
@end