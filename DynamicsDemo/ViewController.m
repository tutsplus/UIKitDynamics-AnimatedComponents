//
//  ViewController.m
//  DynamicsDemo
//
//  Created by Gabriel Theodoropoulos on 31/3/14.
//  Copyright (c) 2014 Gabriel Theodoropoulos. All rights reserved.
//

#import "ViewController.h"
#import "MenuComponent.h"
#import "AlertComponent.h"


@interface ViewController ()

@property (nonatomic, strong) MenuComponent *menuComponent;

-(void)showMenu:(UIGestureRecognizer *)gestureRecognizer;

@property (nonatomic, strong) AlertComponent *alertComponent;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Setup a swipe gesture.
    UISwipeGestureRecognizer *showMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    
    showMenuGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:showMenuGesture];
    
    
    // Initialize the menu component.
    CGRect desiredMenuFrame = CGRectMake(0.0, 20.0, 150.0, self.view.frame.size.height);
    self.menuComponent = [[MenuComponent alloc] initMenuWithFrame:desiredMenuFrame
                                                       targetView:self.view
                                                        direction:menuDirectionRightToLeft
                                                          options:@[@"Download", @"Upload", @"E-mail", @"Settings", @"About"]
                                                     optionImages:@[@"download", @"upload", @"email", @"settings", @"info"]];
    
    
    // Initialize the alert view component.
    self.alertComponent = [[AlertComponent alloc] initAlertWithTitle:@"Custom Alert"
                                                          andMessage:@"You have a new e-mail message, but I don't know from whom."
                                                     andButtonTitles:@[@"Show me", @"I don't care", @"For me, really?"]
                                                       andTargetView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private method implementation.

-(void)showMenu:(UIGestureRecognizer *)gestureRecognizer{
    [self.menuComponent showMenuWithSelectionHandler:^(NSInteger selectedOptionIndex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIKit Dynamics Menu"
                                                        message:[NSString stringWithFormat:@"You selected option #%d", selectedOptionIndex + 1]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
        [alert show];
    }];
}


#pragma mark - IBAction method implementation

- (IBAction)showAlertView:(id)sender {
    [self.alertComponent showAlertViewWithSelectionHandler:^(NSInteger buttonIndex, NSString *buttonTitle) {
        NSLog(@"%ld, %@", (long)buttonIndex, buttonTitle);
    }];
}

@end
