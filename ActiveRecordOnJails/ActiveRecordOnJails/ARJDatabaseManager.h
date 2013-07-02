//
//  ARJDatabaseManager.h
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/03.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSInteger, _ARJDatabaseLocation) {
    ARJDatabaseLocationDocuments,
    ARJDatabaseLocationCache,
    ARJDatabaseLocationTmp,};
typedef enum _ARJDatabaseLocation ARJDatabaseLocation;

@class ARJActiveRecord;
@interface ARJDatabaseManager : NSObject
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) NSArray *models;
@property (nonatomic, assign) ARJDatabaseLocation databaseLocation;
+(ARJDatabaseManager*)defaultManager;
-(BOOL)migrate;
-(id)findModel:(Class)klass condition:(NSDictionary*)condition;
-(id)findFirstModel:(Class)klass condition:(NSDictionary *)condition;
-(NSArray*)allModels:(Class)klass;
-(BOOL)destroyInstance:(id)instance;
-(BOOL)destroyAllModels:(Class)klass;
-(BOOL)saveInstance:(id)instance;
-(id)updateInstance:(id)instance attributes:(NSDictionary*)attributes;
-(id)createModel:(Class)klass attributes:(NSDictionary*)attributes;
-(BOOL)runInTransaction:(BOOL(^)(void))block;
-(BOOL)deleteDB;
+(ARJDatabaseManager*)forRecord:(ARJActiveRecord*)record;
@end
