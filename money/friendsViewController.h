//
//  friendsViewController.h
//  money
//
//  Created by Leah Steinberg on 7/16/14.
//  Copyright (c) 2014 LeahSteinberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface friendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *leftTable;
@property (weak, nonatomic) IBOutlet UITableView *middleTable;

@property (weak, nonatomic) IBOutlet UITableView *rightTable;

@end
