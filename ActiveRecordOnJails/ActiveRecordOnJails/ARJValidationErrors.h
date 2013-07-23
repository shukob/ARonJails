//
//  ARJValidationErrors.h
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARJValidationErrors : NSObject
+(ARJValidationErrors*)errors;
-(void)addErrorMessage:(NSString*)message forKey:(NSString*)key;
-(void)mergeErrors:(ARJValidationErrors*)other;
-(void)mergeErrors:(ARJValidationErrors *)other keyPrefix:(NSString*)keyPrefix;
-(void)addErrorMessages:(NSArray*)messages forKey:(NSString*)key;
-(void)clearErrors;
@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) NSArray * fullMessages;
@end
