//
//  MySlavesViewController.m
//  GLGeofencing
//
//  Created by NAG1-DMAC-26592 on 30/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MySlavesViewController.h"

@interface MySlavesViewController ()

@end

@implementation MySlavesViewController
@synthesize slavesTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    slavesTableView.dataSource = self;
    slavesTableView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)cancelButtonTapped:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)addButtonTapped:(id)sender
{
    NSLog(@"add slaves");
    //TODO: functionality to be added for adding slaves
}


#pragma mark -
#pragma mark UITableView Protocol 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //TODO: number of rows to be returned will be equal to number of slaves registered
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell"; 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //TODO: code to be added to show actual slaves data.
    cell.textLabel.text = [NSString stringWithFormat:@"Slave: %d", indexPath.row+1];
    return cell;
}

@end
