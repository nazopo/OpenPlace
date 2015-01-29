//
//  Place.h
//  Video_JSON
//
//  Created by Nathan Poag on 12/2/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface Place : NSObject
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *place_id;
@property (strong, nonatomic) NSURL *image_url;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) BOOL isOpen;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSData *imgData;
@property (strong, nonatomic) NSData *base64Encoded;
@property (nonatomic) BOOL hasPhotos;
@property (nonatomic, assign) BOOL hasHours;
@property (strong, nonatomic) NSMutableArray *placeHours;
@end
