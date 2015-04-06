//
//  BubbleMessage.h
//  Gosu
//
//  Created by dragon on 3/24/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Message;
@class Task;
@interface BubbleMessage : NSObject

@property (nonatomic) BOOL isMe;
@property (nonatomic) BOOL showAvatar;

@property (nonatomic) MessageType type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *authorPhoto;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSString *authorId;
@property (nonatomic, strong) NSString *attachment;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) CGSize photoSize;

@property (nonatomic) CGSize bubbleSize;
@property (nonatomic) float height;

+ (instancetype)bubbleWithMessage:(Message *)message;
+ (instancetype)bubbleWithTask:(Task *)task;
@end
