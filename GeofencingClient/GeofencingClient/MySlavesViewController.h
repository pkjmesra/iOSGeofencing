//
//  MySlavesViewController.h
//  GLGeofencing
//
//  Created by NAG1-DMAC-26592 on 30/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySlavesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *slavesTableView;
}

@property(strong, nonatomic) IBOutlet UITableView *slavesTableView;

@end