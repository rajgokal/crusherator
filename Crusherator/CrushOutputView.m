//
//  CrushViewController.m
//  Crusherator
//
//  Created by Raj on 4/18/13.
//  Copyright (c) 2013 Raj. All rights reserved.
//

#import "CrushOutputView.h"

@interface CrushOutputView ()

{
    // an array of to-do items
    CrushTaskDatabase* database;
    
    // the offset applied to cells when entering “edit mode”
    float _editingOffset;
    CrushListTableViewCell *cellBeingEdited;
}

@end

@implementation CrushOutputView


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // access database
        database = [[CrushTaskDatabase alloc] init];
        NSLog(@"Work accessed taskInfos with %i tasks",database.taskInfos.count);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.tableView.dataSource = self;
    //    [self.tableView registerClass:[CrushListTableViewCell class] forCellReuseIdentifier:@"cell"];
    //
    //    self.tableView.delegate = self;
    //
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor redColor];
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.tableView registerClassForCells:[CrushListTableViewCell class]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIColor*)colorForIndex:(NSInteger) index
{
    NSUInteger itemCount = database.taskInfos.count - 1;
    float val = ((float)index / (float)itemCount) * 0.6;
    return [UIColor colorWithRed: 1.0 green:val blue: 0.0 alpha:1.0];
}

#pragma mark - UITableViewDataDelegate protocol methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(CrushListTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}

#pragma mark - CrushTableViewDataSource methods
-(NSInteger)numberOfRows
{
    return database.taskInfos.count;
}

-(UITableViewCell *)cellForRow:(NSInteger)row
{
    CrushListTableViewCell* cell = (CrushListTableViewCell*)[self.tableView dequeueReusableCell];
    CrushTaskInfo *item = database.taskInfos[row];
    cell.toDoItem = item;
    cell.delegate = self;
    cell.backgroundColor = [self colorForIndex:row];
    return cell;
}

-(void)toDoItemDeleted:(CrushTaskInfo *)todoItem
{
    float delay = 0.5;
    
    [database removeTask:todoItem];
    
    // find the visible cells
    NSArray* visibleCells = [self.tableView visibleCells];
    
    UIView* lastView = [visibleCells lastObject];
    bool startAnimating = false;
    
    // iterate over all of the cells
    for(CrushListTableViewCell* cell in visibleCells) {
        if (startAnimating) {
            [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                cell.frame = CGRectOffset(cell.frame, 0.0f, -cell.frame.size.height);
            } completion:^(BOOL finished){
                if (cell == lastView) {
                    [self.tableView reloadData];
                }
            }];
            delay+=0.01;
        }
        // if we have reached the item that was deleted, start animating
        if (cell.toDoItem == todoItem) {
            startAnimating = true;
            cell.hidden = YES;
        }
    }
}

-(void)reload
{
    float delay = 0.5;
    
    // find the visible cells
    NSArray* visibleCells = [self.tableView visibleCells];
    
    UIView* lastView = [visibleCells lastObject];
    bool startAnimating = false;
    
    // iterate over all of the cells
    for(CrushListTableViewCell* cell in visibleCells) {
        if (startAnimating) {
            [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                cell.frame = CGRectOffset(cell.frame, 0.0f, -cell.frame.size.height);
            } completion:^(BOOL finished){
                if (cell == lastView) {
                    [self.tableView reloadData];
                }
            }];
            delay+=0.01;
        }
        // if we have reached the item that was deleted, start animating
            startAnimating = true;
            cell.hidden = YES;
    }
}

-(void)cellDidBeginEditing:(CrushListTableViewCell *)editingCell
{
    //    NSLog(@"1 %@",cellBeingEdited.toDoItem.text);
    //    if (cellBeingEdited!=NULL && cellBeingEdited!=editingCell){
    //        [self dismissKeyboard];
    //        NSLog(@"if statement");
    //        [editingCell textFieldShouldReturn:editingCell.label];
    //        cellBeingEdited = NULL;
    //        return;
    //    }
    //    else {
    cellBeingEdited = editingCell;
    //    }
    //    NSLog(@"2 %@",cellBeingEdited.toDoItem.text);
    //    NSLog(@"3 %@",cellBeingEdited.toDoItem.text);
    _editingOffset = _tableView.scrollView.contentOffset.y - editingCell.frame.origin.y;
    for(CrushListTableViewCell* cell in [_tableView visibleCells]) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             cell.frame = CGRectOffset(cell.frame, 0, _editingOffset);
                             if (cell != editingCell) {
                                 cell.alpha = 0.3;
                             }
                         }];
    }
}

-(void)cellDidEndEditing:(CrushListTableViewCell *)editingCell
{
    //    NSLog(@"done editing %@",cellBeingEdited);
    //    cellBeingEdited = NULL;
    for(CrushListTableViewCell* cell in [_tableView visibleCells]) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             cell.frame = CGRectOffset(cell.frame, 0, -_editingOffset);
                             if (cell != editingCell)
                             {
                                 cell.alpha = 1.0;
                             }
                         }];
    }
}

-(void)itemAdded
{
    // create the new item
    CrushTaskInfo* todoItem = [database addTask:@"task name"];
    
    // refresh the table
    [_tableView reloadData];
    // enter edit mode
    CrushListTableViewCell* editCell;
    for (CrushListTableViewCell* cell in _tableView.visibleCells) {
        if (cell.toDoItem == todoItem) {
            editCell = cell;
            break;
        }
    }
    [editCell.label becomeFirstResponder];
}

-(void)dismissKeyboard
{
    [cellBeingEdited textFieldShouldReturn:cellBeingEdited.label];
}

@end

