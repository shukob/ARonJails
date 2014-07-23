//
//  ARJScope.h
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/04.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARJSQLInvocation.h"
extern NSString * const ARJScopeSQLString;
extern NSString * const ARJScopeSQLParameters;
@interface ARJScope : NSObject

+(ARJScope*)INSERT;
+(ARJScope*)SELECT;
+(ARJScope*)UPDATE:(NSString*)tableName;
+(ARJScope*)DELETE;

-(NSDictionary*)SQL;
-(ARJSQLInvocation*)SQLInvocation;

-(ARJScope*)FROM:(NSString*)tableName;
-(ARJScope*)INTO:(NSString*)tableName;
-(ARJScope*)WHERE:(id)where, ...;
-(ARJScope*)ORDER:(NSString*)order;
-(ARJScope*)JOINS:(NSString*)joins;
-(ARJScope*)COLUMNS:(NSString*)aColumn, ...;
-(ARJScope*)COUNT;
-(ARJScope*)ALL;
-(ARJScope*)LIMIT:(NSInteger)limit;
-(ARJScope*)OFFSET:(NSInteger)offset;
-(ARJScope*)SET:(id)data,...;
-(ARJScope*)VALUES:(NSString*)aValue, ...;
-(ARJScope*)COLUMNS:(NSArray*)columns VALUES:(NSArray*)values;
-(ARJScope*)COLUMNS_AND_VALUES:(NSDictionary*)dictionary;
@end
