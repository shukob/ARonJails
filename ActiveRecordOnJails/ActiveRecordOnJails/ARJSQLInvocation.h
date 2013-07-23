//
//  ARJSQLInvocation.h
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARJActiveRecordHelper.h"

@class ARJDatabaseManager;
typedef enum _ARJSQLInvocationType{
    ARJSQLInvocationTypeNone,
   ARJSQLInvocationTypeSelect,
   ARJSQLInvocationTypeUpdate,
   ARJSQLInvocationTypeDelete,
   ARJSQLInvocationTypeInsert,
}ARJSQLInvocationType;

extern NSString * ARJSQLInvocationSQLStringSpecifier;
extern NSString * ARJSQLInvocationSQLParametersSpecifier;
extern NSString * ARJSQLInvocationTypeSpecifier;

@interface ARJSQLInvocation : NSObject
@property (nonatomic, strong) NSDictionary * dictionary;
@property (nonatomic, readonly) NSArray * parameters;
@property (nonatomic, readonly) NSString * SQLString;

-(id)initWithDictionary:(NSDictionary*)dictionary;
+(ARJSQLInvocation*)SQLInvocationWithDictionary:(NSDictionary*)dictionary;
-(id)invokeInDatabaseManager:(ARJDatabaseManager*)manager;
@end
