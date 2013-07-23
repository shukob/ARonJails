//
//  ARJModelAttribute.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/21.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJModelAttribute.h"
#import "ARJActiveRecord.h"
#import "ARJBlobAttribute.h"
#import "ARJIntegerAttribute.h"
#import "ARJFloatAttribute.h"
#import "ARJDateTimeAttribute.h"
#import "ARJStringAttribute.h"
@implementation ARJModelAttribute
@synthesize columnName = _columnName, dictionary = _dictionary, columnTypeString = _columnTypeString;

+(ARJModelAttribute*)modelAttributeWithDictionary:(NSDictionary*)dictionary{
    ARJModelAttribute * res  = nil;
    if ([dictionary[ARJAttributeTypeSpecifier]isEqualToString:ARJBlobAttributeSpecifier]) {
        res = [[ARJBlobAttribute alloc]initWithDictionary:dictionary];
    }else if([dictionary[ARJAttributeTypeSpecifier]isEqualToString:ARJDateTimeAttributeSpecifier]){
        res = [[ARJDateTimeAttribute alloc]initWithDictionary:dictionary];
    }else if([dictionary[ARJAttributeTypeSpecifier]isEqualToString:ARJFloatAttributeSpecifier]){
        res = [[ARJFloatAttribute alloc]initWithDictionary:dictionary];
    }else if([dictionary[ARJAttributeTypeSpecifier]isEqualToString:ARJIntegerAttributeSpecifier]){
        res = [[ARJIntegerAttribute alloc]initWithDictionary:dictionary];
    }else if([dictionary[ARJAttributeTypeSpecifier]isEqualToString:ARJStringAttributeSpecifier]){
        res = [[ARJStringAttribute alloc]initWithDictionary:dictionary];
    }
    return res;
}

-(id)initWithDictionary:(NSDictionary*)dictionary{
    if ([super init]) {
        self.dictionary = dictionary;
    }
    return self;
}

-(NSString*)columnTypeString{
    [self doesNotRecognizeSelector:@selector(columnTypeString)];
    return nil;
}

-(NSString*)columnName{
    return self.dictionary[ARJAttributeNameSpecifier];
}

-(NSString*)propertyName{
    if (self.dictionary[ARJPropertyNameSpecifier]) {
        return self.dictionary[ARJPropertyNameSpecifier];
    }else{
        return self.columnName;
    }
}

-(id)valueForInstance:(ARJActiveRecord *)instance{
    return [instance latestValueForKey:self.columnName];
}

-(void)setValue:(id)attribute forInstance:(ARJActiveRecord*)instance{
    instance.changed = YES;
    instance._updateDictionary[self.columnName]=attribute;
}

-(id)defaultValue{
    return self.dictionary[ARJAttributeDefaultValueSpecifier];
}

-(BOOL)nullable{
    if (self.dictionary[ARJAttributeNullSpecifier]) {
        return [self.dictionary[ARJAttributeNullSpecifier]boolValue];
    }else{
        return YES;
    }
}

-(NSString*)defaultValueSpecifier{
    return [NSString stringWithFormat:@"%@", self.defaultValue];
}

@end
