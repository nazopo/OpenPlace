//
//  DetailCell.h
//  Video_JSON
//
//  Created by Nathan Poag on 12/19/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *placeName;
@property (nonatomic, weak) IBOutlet UILabel *placeDescription;
@property (nonatomic, weak) IBOutlet UIImageView *placeImage;
@end