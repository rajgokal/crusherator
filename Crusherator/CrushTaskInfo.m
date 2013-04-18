//
//  CrushTaskData.m
//  Crusherator
//
//  Created by Raj on 4/14/13.
//  Copyright (c) 2013 Raj. All rights reserved.
//

#import "CrushTaskInfo.h"

@implementation CrushTaskInfo

static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *insert_statement = nil;
@synthesize uniqueId = _uniqueId;
@synthesize text = _text;
@synthesize works = _works;
@synthesize completed = _completed;
@synthesize deleted = _deleted;
@synthesize dateCreated = _dateCreated;
@synthesize dateCompleted = _dateCompleted;
@synthesize dateDeleted = _dateDeleted;
@synthesize category = _category;
@synthesize project = _project;

+ (NSInteger)insertIntoDatabase:(sqlite3 *)database {
    CrushTaskDatabase *taskDatabase = [[CrushTaskDatabase alloc] init];
    database = taskDatabase.databaseAccess;
    
    // When delegate is applied this will return an NSInteger
        static char *sql = "INSERT INTO tasks (text,completed) VALUES('','0')";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    int success = sqlite3_step(insert_statement);
    
    sqlite3_reset(insert_statement);
    if (success != SQLITE_ERROR) {
        return sqlite3_last_insert_rowid(database);
    }
    NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    return -1;
    
}

- (id)initWithUniqueId:(int)uniqueId
                  text:(NSString *)text
{
    if ((self = [super init])) {
        
        CrushTaskDatabase *taskDatabase = [[CrushTaskDatabase alloc] init];
        _database = taskDatabase.databaseAccess;
        
        if (init_statement == nil) {
            const char *sql = "SELECT text,completed FROM tasks WHERE uniqueId = ?";
            if (sqlite3_prepare_v2(_database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_database));
            }
        }
        
        sqlite3_bind_int(init_statement, 1, uniqueId);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
            self.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
			self.completed = sqlite3_column_int(init_statement,1);
            NSLog(@"task initiated with complete = %i",_completed);
        } else {
            self.text = @"Nothing";
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
//        
//        self.uniqueId = uniqueId;
//        self.text = text;
//        self.works = FALSE;
//        self.completed = FALSE;
//        self.deleted = FALSE;
//        self.dateCreated = [NSDate date];
//        self.dateCompleted = NULL;
//        self.dateDeleted = NULL;
//        self.category = NULL;
//        self.project = NULL;
    }
    
    _uniqueId = uniqueId;
    
    return self;
}

- (void) reset {
    self.text = nil;
//    self.works = 0;
    self.deleted = nil;
//    self.dateCreated = nil;
//    self.dateCompleted = nil;
//    self.dateDeleted = nil;
//    self.category = nil;
//    self.project = nil;
}

- (void) dehydrate {
    if (dehydrate_statement == nil) {
        const char *sql = "UPDATE tasks SET text = ? , completed = ? WHERE uniqueId=?";
        if (sqlite3_prepare_v2(_database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_database));
        }
    }
    
    sqlite3_bind_int(dehydrate_statement, 3, self.uniqueId);
    sqlite3_bind_int(dehydrate_statement, 2, self.completed);
    NSLog(@"database updated with complete = %i",_completed);
    sqlite3_bind_text(dehydrate_statement, 1, [self.text UTF8String], -1, SQLITE_TRANSIENT);
    int success = sqlite3_step(dehydrate_statement);
    
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to save changes with message '%s'.", sqlite3_errmsg(_database));
    }
    sqlite3_reset(dehydrate_statement);
}

-(void) deleteFromDatabase {
	if (delete_statement == nil) {
		const char *sql = "DELETE FROM tasks WHERE uniqueId=?";
		if (sqlite3_prepare_v2(_database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_database));
		}
	}
	
	sqlite3_bind_int(delete_statement, 1, self.uniqueId);
	int success = sqlite3_step(delete_statement);
	
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to save priority with message '%s'.", sqlite3_errmsg(_database));
	}
	sqlite3_reset(delete_statement);
}


@end
