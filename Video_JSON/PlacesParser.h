//
//  PlacesParser.h
//  Video_JSON
//
//  Created by Nathan Poag on 12/2/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

@interface PlacesParser : NSObject
@property (strong, nonatomic) Place *value;
-(void)returnSurface:(NSMutableArray*)passedJSON;
@end
