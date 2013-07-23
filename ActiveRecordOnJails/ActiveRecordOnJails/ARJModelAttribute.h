//
//  ARJModelAttribute.h
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/21.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARJActiveRecordHelper.h"

@class ARJActiveRecord;

@interface ARJModelAttribute : NSObject
+(ARJModelAttribute*)modelAttributeWithDictionary:(NSDictionary*)dictionary;
-(id)initWithDictionary:(NSDictionary*)dictionary;
@property (nonatomic, readonly) NSString *columnName;
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, readonly) NSString *columnTypeString;
@property (nonatomic, readonly) NSString *propertyName;
@property (nonatomic, readonly) id defaultValue;
@property (nonatomic, readonly) BOOL nullable;
@property (nonatomic, readonly) NSString * defaultValueSpecifier;
-(id)valueForInstance:(ARJActiveRecord*)instance;
-(void)setValue:(id)attribute forInstance:(ARJActiveRecord*)instance;
@end
