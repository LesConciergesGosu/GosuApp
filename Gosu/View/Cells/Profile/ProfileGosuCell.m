//
//  ProfileGosuCell.m
//  Gosu
//
//  Created by dragon on 5/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ProfileGosuCell.h"
#import "GosuRelation+Extra.h"
#import "User+Extra.h"
#import "DataManager.h"

@interface ProfileGosuCell()


@property (nonatomic, weak) GosuRelation *relation_;
@end

@implementation ProfileGosuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setData:(GosuRelation *)data
{
    self.relation_ = data;
    
    //    if (aTask == nil || [aTask isFault])
    //        return;
    
    if (data == nil)
        return;
    
    User *user = [self.relation_ to];
    [self titleLabel].text = [user fullName];
    
    [self photoView].image = [UIImage imageNamed:@"buddy"];
    NSString *photoUrlString = [user photo];
    if (photoUrlString)
    {
        __weak ProfileGosuCell *wself = self;
        [[DataManager manager] loadImageURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:photoUrlString]] handler:^(UIImage *image) {
            ProfileGosuCell *sself = wself;
            if (sself && sself.relation_ == data && image) {
                [sself photoView].image = image;
            }
        }];
    }
}

- (IBAction) onRemove:(id)sender {
    [self.delegate profileGosuCellRemove:self];
}


@end
