//
//  ARJPropertyObserver.h
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/17.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ARJActiveRecord;
@interface ARJPropertyObserver : NSObject
-(void)registerForPropertyObservation:(ARJActiveRecord*)modelInstance;
+(ARJPropertyObserver*)defaultObserver;
@end
