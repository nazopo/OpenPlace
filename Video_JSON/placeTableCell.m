//
//  placeTableCell.m
//  Video_JSON
//
//  Created by Nathan Poag on 12/22/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import "placeTableCell.h"

@implementation placeTableCell
@synthesize placeName = _placeName;
@synthesize placeDescription = _placeDescription;
@synthesize placeImage = _placeImage;
@synthesize isOpenLabel = _isOpenLabel;

- (void)setFrame:(CGRect)frame {
    frame.origin.y += 4;
    frame.size.height -= 2 * 4;
    [super setFrame:frame];
}
@end
