//
//  BSJSQLiteManager.m
//  iOSProject
//
//  Created by HuXuPeng on 2018/1/26.
//  Copyright © 2018年 github.com/njhu. All rights reserved.
//

#import "BSJSQLiteManager.h"

static NSString *const _dbName = @"bsj_t_topics.sqlite";

static NSString *_dbPath = nil;

@implementation BSJSQLiteManager

+ (void)load
{
    _dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:_dbName];
    NSLog(@"%@", _dbPath);
}

// 查询
- (void)queryArrayOfDicts:(NSString *)sql completion:(void(^)(NSMutableArray<NSMutableDictionary *> *dictArrayM))completion
{
    
    NSMutableArray<NSMutableDictionary *> *dictArrayM = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:sql withArgumentsInArray:@[]];
        
        while (resultSet.next) {
            
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            
            for (int i = 0; i < resultSet.columnCount; i++) {
                
                
                NSString *colName = [resultSet columnNameForIndex:i];
                
                NSString *colValue = [resultSet objectForColumn:colName];
                
                dictM[colName] = colValue;
            }
            
            [dictArrayM addObject:dictM];
        }
        
        
        completion(dictArrayM);
        
    }];
    
    
}


#pragma mark - creatTable
- (void)creatTable
{
    
    NSString *creatTableSql = @"CREATE TABLE IF NOT EXISTS t_topics \n\
    (id INTEGER PRIMARY KEY AUTOINCREMENT, \n\
    topicid TEXT NOT NULL, \n\
    topic BLOB NOT NULL, \n\
    a TEXT NOT NULL, \n\
    type TEXT NOT NULL, \n\
    t INTEGER NOT NULL, \n\
    time TEXT NOT NULL  DEFAULT (datetime('now', 'localtime'))\n\
    )\n";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeStatements:creatTableSql];
        
        if (result) {
            NSLog(@"创建表成功");
        }else {
            NSLog(@"创建表失败");
        }
        
    }];
    
}

#pragma mark - getter
- (FMDatabaseQueue *)dbQueue
{
    if(_dbQueue == nil)
    {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    }
    return _dbQueue;
}








#pragma mark - 单例
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self creatTable];
    }
    return self;
}


static id _instance = nil;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    });
    
    return _instance;
}

@end
