//
//  AlertComponent.m
//  DynamicsDemo
//
//  Created by Gabriel Theodoropoulos on 31/3/14.
//  Copyright (c) 2014 Gabriel Theodoropoulos. All rights reserved.
//

#import "AlertComponent.h"

@interface AlertComponent()

@property (nonatomic, strong) UIView *alertView;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *targetView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSArray *buttonTitles;

@property (nonatomic) CGRect initialAlertViewFrame;

@property (nonatomic, strong) void(^selectionHandler)(NSInteger, NSString *);


-(void)setupBackgroundView;

-(void)setupAlertView;

-(void)handleButtonTap:(UIButton *)sender;

@end



@implementation AlertComponent

-(id)initAlertWithTitle:(NSString *)title andMessage:(NSString *)message andButtonTitles:(NSArray *)buttonTitles andTargetView:(UIView *)targetView{
    if (self = [super init]) {
        // Assign the parameter values to local properties.
        self.title = title;
        self.message = message;
        self.targetView = targetView;
        
        if (buttonTitles != nil) {
            self.buttonTitles = [NSArray arrayWithArray:buttonTitles];
        }
        
        // Setup the background view.
        [self setupBackgroundView];
        
        // Setup the alert view.
        [self setupAlertView];
        
        
        // Setup the animator.
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.targetView];
    }
    
    return self;
}


#pragma mark - Private method implementation

-(void)setupAlertView{
    CGPoint centerPoint = self.targetView.center;
    
    // Set the size of the alert view.
    CGSize alertViewSize = CGSizeMake(250.0, 130.0 + 50.0 * self.buttonTitles.count);
    
    // Set the initial origin point depending on the direction of the alert view.
    CGPoint initialOriginPoint = CGPointMake(centerPoint.x, self.targetView.frame.origin.y - alertViewSize.height);
    
    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(initialOriginPoint.x, initialOriginPoint.y, alertViewSize.width, alertViewSize.height)];
    
    // Background color.
    [self.alertView setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0]];
    
    // Make the alert view with rounded corners.
    [self.alertView.layer setCornerRadius:10.0];
    
    // Set a border to the alert view.
    [self.alertView.layer setBorderWidth:1.0];
    [self.alertView.layer setBorderColor:[UIColor blackColor].CGColor];
    
    // Assign the initial alert view frame to the respective property.
    self.initialAlertViewFrame = self.alertView.frame;
    
    
    // Setup the title label.
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, self.alertView.frame.size.width, 40.0)];
    [self.titleLabel setText:self.title];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14.0]];
    
    // Add the title label to the alert view.
    [self.alertView addSubview:self.titleLabel];
    
    
    // Setup the message label.
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height, self.alertView.frame.size.width, 80.0)];
    [self.messageLabel setText:self.message];
    [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
    [self.messageLabel setFont:[UIFont fontWithName:@"Avenir" size:14.0]];
    [self.messageLabel setNumberOfLines:3];
    [self.messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    // Add the message label to the alert view.
    [self.alertView addSubview:self.messageLabel];
    
    
    CGFloat lastSubviewBottomY = self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height;
    
    
    for (int i=0; i<[self.buttonTitles count]; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10.0, lastSubviewBottomY + 5.0, self.alertView.frame.size.width - 20.0, 40.0)];
        [button setTitle:[self.buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"Avenir" size:13.0]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
        [button setBackgroundColor:[UIColor colorWithRed:0.0 green:0.47 blue:0.39 alpha:1.0]];
        [button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i + 1];
        
        [self.alertView addSubview:button];
        
        lastSubviewBottomY = button.frame.origin.y + button.frame.size.height;
    }
    
    
    // Add the alert view to the parent view.
    [self.targetView addSubview:self.alertView];
}


-(void)setupBackgroundView{
    self.backgroundView = [[UIView alloc] initWithFrame:self.targetView.frame];
    [self.backgroundView setBackgroundColor:[UIColor grayColor]];
    [self.backgroundView setAlpha:0.0];
    [self.targetView addSubview:self.backgroundView];
}


-(void)handleButtonTap:(UIButton *)sender{
    // Call the selection handler.
    self.selectionHandler(sender.tag, sender.titleLabel.text);
    
    // Remove all behaviors from animator.
    [self.animator removeAllBehaviors];
    
    // Add the new behaviors.
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.alertView] mode:UIPushBehaviorModeInstantaneous];
    [pushBehavior setAngle:M_PI_2 magnitude:20.0];
    [self.animator addBehavior:pushBehavior];
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.alertView]];
    [gravityBehavior setGravityDirection:CGVectorMake(0.0, -1.0)];
    [self.animator addBehavior:gravityBehavior];
    
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.alertView]];
    [collisionBehavior addBoundaryWithIdentifier:@"alertCollisionBoundary"
                                       fromPoint:CGPointMake(self.initialAlertViewFrame.origin.x, self.initialAlertViewFrame.origin.y - 10.0)
                                         toPoint:CGPointMake(self.initialAlertViewFrame.origin.x + self.initialAlertViewFrame.size.width, self.initialAlertViewFrame.origin.y - 10.0)];
    [self.animator addBehavior:collisionBehavior];
    
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.alertView]];
    itemBehavior.elasticity = 0.4;
    [self.animator addBehavior:itemBehavior];
    
    
    [UIView animateWithDuration:2.0 animations:^{
        [self.backgroundView setAlpha:0.0];
    }];
}


#pragma mark - Public method implementation


-(void)showAlertViewWithSelectionHandler:(void (^)(NSInteger, NSString *))handler{
    self.selectionHandler = handler;
    
    [self.animator removeAllBehaviors];
    
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:self.alertView snapToPoint:self.targetView.center];
    snapBehavior.damping = 0.8;
    [self.animator addBehavior:snapBehavior];
    
    
    [UIView animateWithDuration:0.75 animations:^{
        [self.backgroundView setAlpha:0.5];
    }];
}


@end
