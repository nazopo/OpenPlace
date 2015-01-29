//
//  placeTableCell.h
//  Video_JSON
//
//  Created by Nathan Poag on 12/22/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface placeTableCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *placeName;
@property (nonatomic, weak) IBOutlet UILabel *placeDescription;
@property (nonatomic, weak) IBOutlet UIImageView *placeImage;
@property (nonatomic, weak) IBOutlet UILabel *isOpenLabel;
@property (nonatomic, weak) IBOutlet UILabel *placeHours;
@property (nonatomic, weak) IBOutlet UILabel *noImageIndicator;
@property (nonatomic, assign) BOOL displayingHours;
@property NSString *placeHoursTemp;
@end
