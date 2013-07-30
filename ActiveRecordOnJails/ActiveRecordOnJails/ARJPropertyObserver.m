//
//  ARJPropertyObserver.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/17.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJPropertyObserver.h"
#import "ARJActiveRecord.h"
#import "ARJModelAttribute.h"
#import "ARJRelation.h"
@implementation ARJPropertyObserver

-(void)registerForPropertyObservation:(ARJActiveRecord*)modelInstance{
#ifndef ARJ_USE_DYNAMIC_METHOD_IMP
    NSDictionary *attributes = [[modelInstance class]attributes];
    for(NSString *attributeName in attributes.allKeys){
        if ([attributeName isEqualToString:@"id"]) {
            continue;
        }
        ARJModelAttribute *attribute = attributes[attributeName];
        NSString *keyPath = attribute.propertyName;
        [modelInstance addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:(void*)attribute.columnName];
    }
    NSDictionary *relations = [[modelInstance class]relations];
    for (NSString * relationName in relations.allKeys){
        NSString *keyPath = relationName;
        [modelInstance addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:(void*)relationName];
    }
#endif
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
#ifndef ARJ_USE_DYNAMIC_METHOD_IMP
    id newValue = change[NSKeyValueChangeNewKey];
    NSString *columnName = (__bridge NSString*)context;
    if ([[object class]attributes][keyPath]) {
        if (newValue) {
            [object setAttribute:newValue forKey:columnName];
        }
    }else if([[object class]relations][keyPath]){
        if (newValue) {
            [object setAssociated:newValue forKey:keyPath];
        }
    }
#endif
}

static ARJPropertyObserver* ___instance;
+(ARJPropertyObserver*)defaultObserver{
    if (!___instance) {
        ___instance = [ARJPropertyObserver new];
    }
    return ___instance;
}

-(void)unRegister:(ARJActiveRecord *)modelInstance{
#ifndef ARJ_USE_DYNAMIC_METHOD_IMP
    NSDictionary *attributes = [[modelInstance class]attributes];
    for(NSString *attributeName in attributes.allKeys){
        if ([attributeName isEqualToString:@"id"]) {
            continue;
        }
        ARJModelAttribute *attribute = attributes[attributeName];
        NSString *keyPath = attribute.propertyName;
        [modelInstance removeObserver:self forKeyPath:keyPath];
    }
    NSDictionary *relations = [[modelInstance class]relations];
    for (NSString * relationName in relations.allKeys){
        NSString *keyPath = relationName;
        [modelInstance removeObserver:self forKeyPath:keyPath];
    }
#endif
}

@end
