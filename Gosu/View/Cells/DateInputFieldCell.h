//
//  DateInputFieldCell.h
//  Gosu
//
//  Created by dragon on 6/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BaseInputFieldCell.h"

@interface DateInputFieldCell : BaseInputFieldCell

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@end
