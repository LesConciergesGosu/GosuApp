//
//  BubbleMessage.m
//  Gosu
//
//  Created by dragon on 3/24/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BubbleMessage.h"
#import "Task+Extra.h"
#import "Message+Extra.h"
#import "User+Extra.h"

@implementation BubbleMessage

+ (instancetype)bubbleWithTask:(Task *)task
{
    BubbleMessage *res = [[BubbleMessage alloc] init];
    
    res.type = MessageTypeDescription;
    res.authorPhoto = [task customer].photo;
    res.date = task.date;
    res.height = 50;
    res.authorName = [task customer].fullName;
    res.authorId = [task customer].objectId;
    
    res.text = task.desc;
    res.attachment = task.voice;
    res.showAvatar = YES;
    
    return res;
}

+ (instancetype)bubbleWithMessage:(Message *)aMessage
{
    BubbleMessage *res = [[BubbleMessage alloc] init];
    
    res.type = [aMessage.type intValue];
    res.authorPhoto = [aMessage author].photo;
    res.date = aMessage.date;
    res.height = 50;
    res.authorName = [aMessage author].fullName;
    res.authorId = [aMessage author].objectId;
    
    switch (res.type) {
            
        case MessageTypeText:
            res.text = aMessage.text;
            break;
            
        case MessageTypePhoto:
            res.photoSize = CGSizeMake([aMessage.photoWidth floatValue],
                                       [aMessage.photoHeight floatValue]);
            res.attachment = aMessage.file;
            break;
        case MessageTypeAudio:
            res.attachment = aMessage.file;
            break;
            
        case MessageTypeNotification:
            res.text = aMessage.text;
            res.attachment = aMessage.file;
            break;
            
        default:
            break;
            
    }
    
    
    return res;
}

@end
