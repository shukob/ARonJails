//
//  ARJRelation.h
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/17.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ARJActiveRecord, ARJDatabaseManager;

typedef enum _ARJRelationDependency{
    ARJRelationDependencyNone,
    ARJRelationDependencyDestroy,
    ARJRelationDependencyNullify,
}ARJRelationDependency;

@interface ARJRelation : NSObject
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, weak) Class sourceModel;

+(ARJRelation*)relationWithDictionary:(NSDictionary*)dictionary forModel:(Class)klass;

-(id)initWithDictionary:(NSDictionary*)dictionary forModel:(Class)model;
-(BOOL)willDestroySourceInstance:(ARJActiveRecord*)instance;
-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source;
-(id)destinationForSource:(ARJActiveRecord*)source;
-(BOOL)willDestroySourceInstance:(ARJActiveRecord*)instance inDatabaseManager:(ARJDatabaseManager*)manager;
-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source inDatabaseManager:(ARJDatabaseManager*)manager;
-(id)destinationForSource:(ARJActiveRecord*)source inDatabaseManager:(ARJDatabaseManager*)manager;
-(NSString*)inverseRelationKey;
+(ARJDatabaseManager*)expectedDatabaseManagerForSource:(ARJActiveRecord*)source andDestination:(id)destination;
-(id)blankValue;
-(BOOL)saveDestination:(id)destination forSource:(ARJActiveRecord*)source;
@property (nonatomic, readonly) NSDictionary *attributes;
@property (nonatomic, readonly) NSString *relationName;
@property (nonatomic, readonly) NSString *foreignKey;
@property (nonatomic, readonly) NSString *associationKey;
@property (nonatomic, readonly) NSString *foreignClassName;
@property (nonatomic, readonly) ARJRelationDependency dependency;
@property (nonatomic, readonly) Class destinationModel;
@property (nonatomic, readonly) ARJRelation *inverseRelation;
@property (nonatomic, readonly) BOOL autosave;

@end
