//
//  multiTableViewAppDelegate.h
//  Video_JSON
//
//  Created by Nathan Poag on 12/22/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import  <UIKit/UIKit.h>

@class multiTableViewController;

@interface multiTableViewAppDelegate : NSObject <UIApplicationDelegate>{
    UIWindow *window;
    multiTableViewController *viewController;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet multiTableViewController *viewController;


@end
