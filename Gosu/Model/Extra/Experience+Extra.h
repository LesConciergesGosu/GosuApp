//
//  Experience+Extra.h
//  Gosu
//
//  Created by Dragon on 11/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Experience.h"

@class Offer;
@interface Experience (Extra)

+ (instancetype) objectFromParseObject:(id)object inContext:(NSManagedObjectContext *)context;

+ (void) createExperienceWithPFTasks:(NSArray *)pTasks completion:(GCreateObjectBlock)completion;
+ (void) createExperienceWithOffer:(Offer *)offer completion:(GCreateObjectBlock)completion;
+ (void) editExperienceWithId:(NSString *)exprienceId WithPFTasks:(NSArray *)pTasks completion:(GCreateObjectBlock)completion;
+ (void) confirmExperienceWithId:(NSString *)exprienceId WithPFTasks:(NSArray *)pTasks completion:(GCreateObjectBlock)completion;
+ (void) loadMyExperiencesWithCompletionHandler:(GSuccessWithErrorBlock)completion;
+ (void) loadMyExperiencesWithStatus:(NSArray *)statusArray
                   CompletionHandler:(GSuccessWithErrorBlock)completion;
@end
