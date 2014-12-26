//
//  MainTVController.m
//  Video_JSON
//
//  Created by Nathan Poag on 12/22/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import "MainTVController.h"
#import "SearchTVController.h"
@implementation MainTVController
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return 24;
}
@end
