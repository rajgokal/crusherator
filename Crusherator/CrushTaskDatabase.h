//
//  CrushTaskDatabase.h
//  Crusherator
//
//  Created by Raj on 4/14/13.
//  Copyright (c) 2013 Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@class CrushTaskObject;

@interface CrushTaskDatabase : NSObject <UIApplicationDelegate>

{
    sqlite3 *_database;
}

+ (CrushTaskDatabase *)sharedInstance;
- (CrushTaskObject *)addTask:text atIndex:(int)index withPageIndex:(int)pageIndex;
- (void)removeTask:task;
- (void)moveToEnd:(CrushTaskObject *)task;
- (sqlite3 *)databaseAccess;
- (NSMutableArray *)taskInfosForPageIndex:(int)index;

@property (nonatomic, retain) NSMutableArray *retval;

@end
