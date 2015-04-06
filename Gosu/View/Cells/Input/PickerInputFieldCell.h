//
//  PickerInputFieldCell.h
//  Gosu
//
//  Created by dragon on 6/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BaseInputFieldCell.h"

@interface PickerInputFieldCell : BaseInputFieldCell<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@end
