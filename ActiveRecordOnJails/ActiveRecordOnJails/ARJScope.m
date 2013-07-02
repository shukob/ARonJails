//
//  ARJScope.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/04.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJScope.h"
#import "ARJActiveRecordHelper.h"
#import "ARJSQLInvocation.h"
NSString * const ARJScopeSQLString = @"ARJScopeSQLString";
NSString * const ARJScopeSQLParameters = @"ARJScopeSQLParameters";

NSString * const ARJScopeColumnsClause = @"ARJScopeColumnClause";
NSString * const ARJScopeValuesValues = @"ARJScopeValuesValues";
NSString * const ARJScopeMethodClause = @"ARJScopeMethodClause";
NSString * const ARJScopeWhereClause = @"ARJScopeWhereClause";
NSString * const ARJScopeJoinsClause = @"ARJScopeJoinsClause";
NSString * const ARJScopeTargetTableClause = @"ARJScopeTargetTableClause";
NSString * const ARJScopeOrderClause = @"ARJScopeOrderClause";
NSString * const ARJScopeWhereValues = @"ARJScopeWhereValues";
NSString * const ARJScopeLimitValue = @"ARJScopeLimitValue";
NSString * const ARJScopeOffsetValue = @"ARJScopeOffsetValue";
NSString * const ARJScopeSetClause = @"ARJScopeSetClause";
NSString * const ARJScopeSetValues = @"ARJScopeSetValues";

NS_ENUM(NSInteger,_ARJScopeOperationType){
    ARJScopeOperationTypeNone,
    ARJScopeOperationTypeSelect,
    ARJScopeOperationTypeUpdate,
    ARJScopeOperationTypeDelete,
    ARJScopeOperationTypeInsert,
};
typedef enum _ARJScopeOperationType ARJScopeOperationType;

@interface ARJScope()
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, assign) ARJScopeOperationType operationType;
@property (nonatomic, strong) NSString *targetTable;
@property (nonatomic, readonly) ARJSQLInvocationType SQLInvocationType;
@end

@implementation ARJScope

-(id)init{
    if([super init]){
        self.params = [NSMutableDictionary new];
    }
    return self;
}


-(NSDictionary*)SQL{
    NSMutableString * sql= [NSMutableString string];
    [sql appendString:self.params[ARJScopeMethodClause]];
    if (self.operationType == ARJScopeOperationTypeSelect){
        if (self.params[ARJScopeColumnsClause]) {
            NSString * columns =[self.params[ARJScopeColumnsClause]componentsJoinedByString:@", "];
            [sql appendFormat:@" %@ ", columns];
        }else{
            [sql appendFormat:@" * "];
        }
    }
    if (self.params[ARJScopeTargetTableClause]) {
        [sql appendFormat:@"%@ ", self.params[ARJScopeTargetTableClause]];
    }
    
    if (self.params[ARJScopeSetClause]) {
        [sql appendFormat:@"SET "];
        for(NSString *property in self.params[ARJScopeSetClause]){
            [sql appendFormat:@"%@ = ?", property];
            if (property != [self.params[ARJScopeSetClause] lastObject]) {
                [sql appendString:@", "];
            }
        }
        [sql appendString:@" "];
    }
    
    if (self.params[ARJScopeJoinsClause]) {
        NSString * joins = [self.params[ARJScopeJoinsClause] componentsJoinedByString:@", "];
        [sql appendFormat:@"%@ ", joins];
    }
    
    if (self.params[ARJScopeWhereClause]) {
        NSString * wheres =[self.params[ARJScopeWhereClause] componentsJoinedByString:@" AND "];
        [sql appendFormat:@"WHERE %@ ", wheres];
    }
    if(self.params[ARJScopeOrderClause]){
        for(NSString * order in self.params[ARJScopeOrderClause]){
            [sql appendFormat:@"ORDER BY %@ ", order];
            
        }
    }
    
    if (self.params[ARJScopeLimitValue]) {
        [sql appendFormat:@"LIMIT %@ ", self.params[ARJScopeLimitValue]];
    }
    if (self.params[ARJScopeOffsetValue]) {
        [sql appendFormat:@"OFFSET %@", self.params[ARJScopeOffsetValue]];
    }
    
    if ([self.params[ARJScopeValuesValues]count]) {
        [sql appendFormat:@"("];
        for (NSString *column in self.params[ARJScopeColumnsClause]){
            [sql appendString:column];
            if(column != [self.params[ARJScopeColumnsClause]lastObject]){
                [sql appendString:@", "];
            }else{
                [sql appendString:@") VALUES ("];
            }
        }
        for (NSString * value in self.params[ARJScopeValuesValues]){
            [sql appendString:@"?"];
            if(value != [self.params[ARJScopeValuesValues]lastObject]){
                [sql appendString:@", "];
            }else{
                [sql appendString:@") "];
            }
        }
    }else if(self.operationType == ARJScopeOperationTypeInsert){
        [sql appendString:@" DEFAULT VALUES "];
    }
    
    [sql appendString:@";"];
    NSMutableArray * parameters = [NSMutableArray array];
    if (self.params[ARJScopeSetValues]) {
        [parameters addObjectsFromArray:self.params[ARJScopeSetValues]];
    }
    if (self.params[ARJScopeWhereValues]) {
        [parameters addObjectsFromArray:self.params[ARJScopeWhereValues]];
    }
    if (self.params[ARJScopeValuesValues]) {
        [parameters addObjectsFromArray:self.params[ARJScopeValuesValues]];
    }
    return @{ARJScopeSQLString: sql, ARJScopeSQLParameters: parameters};
    
}




+(ARJScope*)INSERT{
    ARJScope * res = [ARJScope new];
    (res.params)[ARJScopeMethodClause] = @"INSERT";
    res.operationType = ARJScopeOperationTypeInsert;
    return res;
}

+(ARJScope*)SELECT{
    ARJScope * res= [ARJScope new];
    (res.params)[ARJScopeMethodClause] = @"SELECT";
    res.operationType = ARJScopeOperationTypeSelect;
    return res;
}

+(ARJScope*)UPDATE:(NSString*)tableName{
    ARJScope * res = [ARJScope new];
    (res.params)[ARJScopeMethodClause] = @"UPDATE ";
    res.params[ARJScopeTargetTableClause] = tableName;
    res.targetTable = tableName;
    res.operationType = ARJScopeOperationTypeUpdate;
    return res;
}
+(ARJScope*)DELETE{
    ARJScope *res = [ARJScope new];
    (res.params)[ARJScopeMethodClause] = @"DELETE ";
    res.operationType = ARJScopeOperationTypeDelete;
    return res;
}

-(ARJScope*)FROM:(NSString *)tableName{
    self.targetTable = tableName;
    (self.params)[ARJScopeTargetTableClause] = [NSString stringWithFormat:@"FROM %@", tableName];
    return self;
}

-(ARJScope*)INTO:(NSString *)tableName{
    self.targetTable = tableName;
    (self.params)[ARJScopeTargetTableClause] = [NSString stringWithFormat:@" INTO %@",tableName];
    return self;
}

-(ARJScope*)ORDER:(NSString *)order{
    if(!(self.params)[ARJScopeOrderClause]){
        (self.params)[ARJScopeOrderClause] = [NSMutableArray new];
    }
    [(self.params)[ARJScopeOrderClause]addObject:order];
    return self;
}

-(ARJScope*)COLUMNS:(NSString*)aColumn, ...{
    if (!(self.params)[ARJScopeColumnsClause]) {
        (self.params)[ARJScopeColumnsClause] = [NSMutableArray array];
    }
    if(aColumn){
        va_list ap;
        va_start(ap, aColumn);
        for (NSString * column = aColumn; aColumn != nil; aColumn = va_arg(ap, NSString*)) {
            [(self.params)[ARJScopeColumnsClause]addObject:column];
        }
    }
    return self;
}

-(ARJScope*)VALUES:(NSString *)aValue, ...{
    if(!self.params[ARJScopeValuesValues]){
        self.params[ARJScopeValuesValues] = [NSMutableArray array];
    }
    if (aValue) {
        va_list ap;
        va_start(ap, aValue);
        for (id value = aValue; value != Nil; aValue = va_arg(ap, id)) {
            [self.params[ARJScopeValuesValues]addObject:value];
        }
    }
    return self;
    
}

-(ARJScope*)ALL{
    return self;
}

-(ARJScope*)COUNT{
    if (!self.params[ARJScopeColumnsClause]) {
        self.params[ARJScopeColumnsClause] = [NSMutableArray array];
    }
    [self.params[ARJScopeColumnsClause] addObject:@"COUNT(*)"];
    return self;
}

-(ARJScope*)WHERE:(id)where, ...{
    if (where) {
        
        va_list ap;
        va_start(ap, where);
        if (!(self.params)[ARJScopeWhereClause]) {
            (self.params)[ARJScopeWhereClause] = [NSMutableArray array];
        }
        if (!(self.params)[ARJScopeWhereValues]) {
            (self.params)[ARJScopeWhereValues] = [NSMutableArray array];
        }
        for (id param = where; param != nil; param = va_arg(ap, id)){
            
            if ([param isKindOfClass:[NSString class]]) {
                [(self.params)[ARJScopeWhereClause]addObject:param];
            }else if([param isKindOfClass:[NSDictionary class]]){
                for(NSString *key in param){
                    NSString *thisKey = key;
                    if (![[ARJActiveRecordHelper defaultHelper]hasTableSpecificationInString:thisKey]) {
                        thisKey = [[self.targetTable stringByAppendingString:@"."]stringByAppendingString:thisKey];
                    }
                    if (![[ARJActiveRecordHelper defaultHelper]hasValuePlaceholderInString:thisKey]) {
                        thisKey = [thisKey stringByAppendingString:@" = ?"];
                    }
                    [self.params[ARJScopeWhereClause]addObject:thisKey];
                    id value = param[key];
                    if ([value isKindOfClass:[NSArray class]]) {
                        [self.params[ARJScopeWhereValues]addObjectsFromArray:value];
                    }else{
                        [self.params[ARJScopeWhereValues]addObject:value];
                    }

                }
            }
        }
        
        va_end(ap);
    }
    return self;
}

-(ARJScope*)JOINS:(NSString *)joins{
    if (!(self.params)[ARJScopeJoinsClause]) {
        (self.params)[ARJScopeJoinsClause] = [NSMutableArray array];
    }
    return self;
}

-(ARJScope*)LIMIT:(NSInteger)limit{
    (self.params)[ARJScopeLimitValue] = @(limit);
    return self;
}

-(ARJScope*)OFFSET:(NSInteger)offset{
    (self.params)[ARJScopeOffsetValue] = @(offset);
    return self;
}

-(ARJScope*)SET:(id)data, ...{
    if(data){
        va_list ap;
        va_start(ap, data);
        if(!self.params[ARJScopeSetValues]){
            self.params[ARJScopeSetValues] = [NSMutableArray array];
        }
        if(!self.params[ARJScopeSetClause]){
            self.params[ARJScopeSetClause] = [NSMutableArray array];
        }
        
        for (id param = data; param != nil; param = va_arg(ap, id)){
            
            if ([param isKindOfClass:[NSString class]]) {
                [(self.params)[ARJScopeSetClause]addObject:param];
            }else if([param isKindOfClass:[NSDictionary class]]){
                for(NSString *key in [param allKeys]){
                    [self.params[ARJScopeSetClause]addObject:key];
                    [self.params[ARJScopeSetValues]addObject:param[key]];
                    
                }
            }
        }
        
        va_end(ap);
    }
    return self;
}

-(ARJScope*)COLUMNS:(NSArray*)columns VALUES:(NSArray*)values{
    if (!self.params[ARJScopeColumnsClause]) {
        self.params[ARJScopeColumnsClause] = [NSMutableArray array];
    }
    [self.params[ARJScopeColumnsClause]addObjectsFromArray:columns];
    if(!self.params[ARJScopeValuesValues]){
        self.params[ARJScopeValuesValues] = [NSMutableArray array];
    }
    [self.params[ARJScopeValuesValues] addObjectsFromArray:values];
    return self;
}

-(ARJScope*)COLUMNS_AND_VALUES:(NSDictionary*)dictionary{
    if (!self.params[ARJScopeColumnsClause]) {
        self.params[ARJScopeColumnsClause] = [NSMutableArray array];
    }
    if(!self.params[ARJScopeValuesValues]){
        self.params[ARJScopeValuesValues] = [NSMutableArray array];
    }
    for (NSString * key in dictionary.allKeys){
        [self.params[ARJScopeColumnsClause]addObject:key];
        [self.params[ARJScopeValuesValues]addObject:dictionary[key]];
    }
    return self;
}

-(ARJSQLInvocation*)SQLInvocation{
    ARJSQLInvocation * res = nil;
    NSDictionary *sql = [self SQL];
    res = [ARJSQLInvocation SQLInvocationWithDictionary:@{ARJSQLInvocationSQLStringSpecifier : sql[ARJScopeSQLString], ARJSQLInvocationSQLParametersSpecifier : sql[ARJScopeSQLParameters], ARJSQLInvocationTypeSpecifier : @(self.SQLInvocationType)}];
    return res;
}

-(ARJSQLInvocationType)SQLInvocationType{
    ARJSQLInvocationType invocationType = ARJSQLInvocationTypeNone;
    switch (self.operationType) {
        case ARJScopeOperationTypeDelete:
            invocationType = ARJSQLInvocationTypeDelete;
            break;
        case ARJScopeOperationTypeSelect:
            invocationType = ARJSQLInvocationTypeSelect;
            break;
        case ARJScopeOperationTypeInsert:
            invocationType = ARJSQLInvocationTypeInsert;
            break;
        case ARJScopeOperationTypeUpdate:
            invocationType = ARJSQLInvocationTypeUpdate;
            break;
        default:
            break;
    }
    return invocationType;
}

@end
