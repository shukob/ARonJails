//
//  ARJDatabaseManager.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/03.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJDatabaseManager.h"
#import "ARJActiveRecord.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "ARJExpectationHelper.h"
#import "ARJScope.h"
#import "ARJRelation.h"
#import "ARJModelAttribute.h"
#import "ARJSQLInvocation.h"
#import <objc/runtime.h>
@interface ARJDatabaseManager()
@property (nonatomic, strong) FMDatabase * database;
@property (nonatomic, strong) NSRecursiveLock * dbLock;
@end

@implementation ARJDatabaseManager


-(id)init{
    if ([super init]) {
        self.dbLock = [NSRecursiveLock new];
        self.databaseLocation = ARJDatabaseLocationDocuments;
//        [self loadActiveRecords];
    }
    return self;
}

-(void)loadActiveRecords{
    int numClasses = 0;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses < 1) {
        return;
    }else{
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        NSMutableArray *activeRecords = [NSMutableArray array];
        for (int i = 0; i < numClasses; ++i) {
            const char* className = class_getName(classes[i]);
            if (strnstr(className, "_", 2)|| strnstr(className, "Object", 6)) {
                continue;
            }
            Class klass = NSClassFromString([NSString stringWithUTF8String:className]);
            if (klass) {
                if ([klass isSubclassOfClass:[ARJActiveRecord class]] && klass != [ARJActiveRecord class]) {
                    [activeRecords addObject:NSStringFromClass(klass)];
                }
            }
        }
        free(classes);
        self.models = activeRecords;
    }
}

-(NSString*)dbPath{
    NSString * res = nil;
    switch (self.databaseLocation) {
        case ARJDatabaseLocationDocuments:{
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            if (paths.count>0) {
                res = paths[0];
            }
        }
            break;
        case ARJDatabaseLocationCache:{
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            if ([paths count]>0) {
                res = paths[0];
            }
        }
            break;
        case ARJDatabaseLocationTmp:{
            res = NSTemporaryDirectory();
        }
            break;
        default:
            
            break;
    }
    if (res) {
        res = [res stringByAppendingPathComponent:self.dbName];
    }
    return res;
}


-(BOOL)migrate{
    [self.database close];
    NSString * dbPath = [self dbPath];
    if (!dbPath) {
        return NO;
    }
    self.database = [FMDatabase databaseWithPath:dbPath];
    
    if (![self.database open]) {
        return NO;
    }
    self.database.logsErrors = YES;
    self.database.traceExecution = YES;
    return [self runInTransaction:^BOOL(id database){
        for(NSString * model in self.models){
            Class klass = NSClassFromString(model);
            if (klass!=nil) {
                NSString *tableName = [klass tableName];
                if (![self tableNameExists:tableName]) {
                    if (![self createTableName:tableName]) {
                        return NO;
                    }
                }
                [self migrateTableName:tableName withModel:klass];
            }
        }
        return YES;
    }];
}


-(BOOL)tableNameExists:(NSString*)tableName{
    FMResultSet * fmresult = [self.database executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;", tableName]];
    BOOL res = NO;
    
    if (!fmresult ) {
        res = NO;
    }else{
        res = YES;
    }
    [fmresult close];
    return res;
}

-(BOOL)createTableName:(NSString*)tableName{
    BOOL res =  [self.database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT) ;", tableName]];
    if (res) {
        res = [self.database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX %@_id ON %@(id);", tableName, tableName]];
    }
    return res;
}

-(void)migrateTableName:(NSString*)tableName withModel:(Class)klass{
    NSDictionary *attributes = [klass attributes];
    NSDictionary *relations = [klass relations];
    NSMutableDictionary *targetAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    for (ARJRelation *relation in relations.allValues){
        NSDictionary *thisAttributes = [relation attributes];
        if (thisAttributes) {
            [targetAttributes addEntriesFromDictionary:thisAttributes];
        }
    }
    
    [self runInTransaction:^BOOL(id database){
        for (ARJModelAttribute * attribute in [targetAttributes allValues]){
            NSString *columnName = attribute.columnName;;
            NSLog(@"%@", [attribute class]);
            if (![self.database columnExists:columnName inTableWithName:tableName]) {
                NSMutableString *query =[NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, columnName, attribute.columnTypeString];
                if (!attribute.nullable) {
                    [query appendString:@" NOT NULL "];
                }
                if (attribute.defaultValue) {
                    [query appendFormat:@" DEFAULT %@ ", attribute.defaultValueSpecifier];
                }
                [query appendString:@";"];
                if(![self.database executeUpdate:query]){
                    return NO;
                }
            }
            
        }
        return YES;
    }];
}


    
-(NSInteger)countModel:(Class)klass condition:(NSDictionary*)condition{
    ARJScope *scoped = [[klass scoped]COUNT];
    scoped = [scoped WHERE:condition, nil];
    ARJSQLInvocation *invocation = [scoped SQLInvocation];
    __block NSInteger result = 0;
    [self runInTransaction:^BOOL(id database){
        FMResultSet *res = [self.database executeQuery:invocation.SQLString withArgumentsInArray:invocation.parameters];
        
        if(res){
            while ([res next]) {
                result = [res intForColumnIndex:0];
            }
            [res close];
            return YES;
        }else{
            return NO;
        }
        
    }];
    return result;
}

-(id)findModel:(Class)klass invocation:(ARJSQLInvocation *)invocation{
    __block id result = @[];
    [self runInTransaction:^BOOL(id database){
        
        FMResultSet *res = [self.database executeQuery:invocation.SQLString withArgumentsInArray:invocation.parameters];
        
        if(res){
            NSMutableArray *models = [NSMutableArray array];
            while ([res next]) {
                NSDictionary *dict = [res resultDictionary];
                [models addObject:[klass instanceWithDictionary:dict]];
                [[models lastObject]setCorrespondingDatabaseManager:self];
            }
            [res close];
            result = models;
            return YES;
        }else{
            return NO;
        }
        
    }];
    return result;
}

-(id)findModel:(Class)klass condition:(NSDictionary*)condition{
    ARJScope *scoped = [klass scoped];
    scoped = [scoped WHERE:condition, nil];
    ARJSQLInvocation *invocation = [scoped SQLInvocation];
    return [self findModel:klass invocation:invocation];
}


-(id)findFirstModel:(Class)klass invocation:(ARJSQLInvocation *)invocation{
    __block id result = nil;
    [self runInTransaction:^BOOL(id database){
        FMResultSet *res = [self.database executeQuery:invocation.SQLString withArgumentsInArray:invocation.parameters ];
        
        if(res){
            id model = nil;
            while ([res next]) {
                NSDictionary *dict = [res resultDictionary];
                model = [klass instanceWithDictionary:dict];
                [model setCorrespondingDatabaseManager:self];
            }
            [res close];
            result = model;
            return YES;
        }else{
            return NO;
        }
        
    }];
    return result;
}

-(id)findFirstModel:(Class)klass condition:(NSDictionary*)condition{
    ARJScope *scoped = [klass scoped];
    scoped = [[scoped WHERE:condition, nil]LIMIT:1];
    ARJSQLInvocation* invocation = [scoped SQLInvocation];
    return [self findFirstModel:klass invocation:invocation];
    
}

-(NSArray*)allModels:(Class)klass{
    return [self findModel:klass condition:nil];
}


-(BOOL)destroyInstance:(id)instance{
    ARJScope *scoped = [instance destroyScope];
    ARJSQLInvocation *invocation = [scoped SQLInvocation];
    return [self runInTransaction:^BOOL(id database){
        [instance willDestroy];
        BOOL res = [self.database executeUpdate:invocation.SQLString withArgumentsInArray:invocation.parameters];
        return res;
    }];
}

-(BOOL)saveInstance:(id)instance{
    return [self runInTransaction:^BOOL(id database){
        [instance saveAssociated];
        ARJScope *scoped = [instance updateScope];
        [scoped SET:[instance _updateDictionary], nil];
        ARJSQLInvocation *invocation = [scoped SQLInvocation];
        BOOL res =[self.database executeUpdate:invocation.SQLString withArgumentsInArray:invocation.parameters];
        return res;
    }];
}

-(id)updateInstance:(id)instance attributes:(NSDictionary*)attributes{
    ARJScope *scoped = [instance updateScope];
    [scoped SET:attributes, nil];
    ARJSQLInvocation *invocation = [scoped SQLInvocation];
    __block id result = instance;
    [self runInTransaction:^BOOL(id database){
        BOOL res =  [self.database executeUpdate:invocation.SQLString withArgumentsInArray:invocation.parameters];
        return res;
    }];
    return result;
}


-(id)createModel:(Class)klass attributes:(NSDictionary*)attributes{
    ARJScope *scoped = [klass insertScope];
    [scoped COLUMNS_AND_VALUES:attributes];
    ARJSQLInvocation *invocation = [scoped SQLInvocation];
    __block id result = nil;
    __block sqlite_int64 rowId = 0;
    [self runInTransaction:^BOOL(id database){
        BOOL res = [self.database executeUpdate:invocation.SQLString withArgumentsInArray:invocation.parameters];
        NSError *e = [self.database lastError];
        if (e.code) {
            NSLog(@"");
        }
        if(res){
            rowId = self.database.lastInsertRowId;
            result = [klass findFirst:@{[NSString stringWithFormat:@"%@.rowid = ?", [klass tableName]]: @(rowId)} inDatabaseManager:self];
            [result setCorrespondingDatabaseManager:self];
        }else{
            @throw [NSException exceptionWithName:@"ARJDatabaseManagerSQLiteError" reason:@"" userInfo:@{@"error": self.database.lastError}];
        }
        return res;
    }];
    
    return result;
}

-(BOOL)destroyAllModels:(Class)klass{
    ARJScope *scope = [[ARJScope DELETE]FROM:[klass tableName]];
    ARJSQLInvocation *invocation = [scope SQLInvocation];
    return [self runInTransaction:^BOOL(id database){
        return [database executeUpdate:invocation.SQLString];
    }];
}

-(BOOL)runInTransaction:(BOOL(^)(id))block{
    if (self.database.inTransaction) {
        [self.dbLock lock];
        BOOL res = block(self.database);
        [self.dbLock unlock];
        return res;
    }else{
        [self.dbLock lock];
        [self.database beginTransaction];
        BOOL res = block(self.database);
        if (res) {
            [self.database commit];
        }else{
            [self.database rollback];
        }
        [self.dbLock unlock];
        return res;
    }
}

-(BOOL)deleteDB{
    [self.database close];
    NSString *path = [self dbPath];
    return [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
}

static ARJDatabaseManager *___instance;
+(ARJDatabaseManager*)defaultManager{
    if (!___instance) {
        ___instance = [ARJDatabaseManager new];
    }
    return ___instance;
}
+(ARJDatabaseManager*)forRecord:(ARJActiveRecord*)record{
    if (record.correspondingDatabaseManager) {
        return record.correspondingDatabaseManager;
    }else{
        return [self defaultManager];
    }
}

-(void)close{
    [self.dbLock lock];
    [self.database close];
    self.database = nil;
    [self.dbLock unlock];
}

@end
