//
//  ImageTableViewCell.h
//  WannaBee
//
//  Created by Edwin Groothuis on 30/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface ImageTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *subtitle;
@property (nonatomic, weak) IBOutlet UILabel *remark;
@property (nonatomic, weak) IBOutlet UIImageView *image;

@end
