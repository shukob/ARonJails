//
//  ARJFormatValidator.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJFormatValidator.h"
#import "ARJActiveRecord.h"

@interface ARJFormatValidator()
@property (nonatomic, strong) NSRegularExpression *regex;

@end
@implementation ARJFormatValidator

-(id)initWithDictionary:(NSDictionary *)dictionary{
    if ([super initWithDictionary:dictionary]) {
        [self constructRegex];
    }
    return self;
}

-(void)constructRegex{
    NSRegularExpressionOptions option = [self.dictionary[ARJValidationFormatOptionSpecifier]integerValue];
    self.regex = [NSRegularExpression regularExpressionWithPattern:self.dictionary[ARJValidationFormatSpecifier] options:option error:nil];
}

-(NSArray*)validateValue:(id)value{
    NSMutableArray *array = [NSMutableArray array];
    if ([value isKindOfClass:[NSString class]]) {
        NSArray * matches = [self.regex matchesInString:value options:0 range:NSMakeRange(0, [value length])];
        if (!matches.count) {
            [array addObject:[NSString stringWithFormat:@"Format Error: %@", self.regex.pattern]];
        }
    }else{
        
    }
    return array;
}

@end
