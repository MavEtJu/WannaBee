//
//  ItemTableViewCell.h
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface ItemTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *itemName;
@property (nonatomic, weak) IBOutlet UILabel *placeName;
@property (nonatomic, weak) IBOutlet UILabel *setName;
@property (nonatomic, weak) IBOutlet UILabel *numbers;
@property (nonatomic, weak) IBOutlet UILabel *mixing;
@property (nonatomic, weak) IBOutlet UIImageView *image;

@end
