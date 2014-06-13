//
//  MenuComponent.m
//  DynamicsDemo
//
//  Created by Gabriel Theodoropoulos on 31/3/14.
//  Copyright (c) 2014 Gabriel Theodoropoulos. All rights reserved.
//

#import "MenuComponent.h"


@interface MenuComponent()

@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *targetView;

@property (nonatomic, strong) UITableView *optionsTableView;

@property (nonatomic, strong) NSArray *menuOptions;

@property (nonatomic, strong) NSArray *menuOptionImages;

@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic) MenuDirectionOptions menuDirection;

@property (nonatomic) CGRect menuFrame;

@property (nonatomic) CGRect menuInitialFrame;

@property (nonatomic) BOOL isMenuShown;

@property (nonatomic, strong) void(^selectionHandler)(NSInteger);


-(void)setupMenuView;

-(void)setupBackgroundView;

-(void)setupOptionsTableView;

-(void)setInitialTableViewSettings;

-(void)setupSwipeGestureRecognizer;

-(void)hideMenuWithGesture:(UISwipeGestureRecognizer *)gesture;

-(void)toggleMenu;

@end


@implementation MenuComponent

-(id)initMenuWithFrame:(CGRect)frame targetView:(UIView *)targetView direction:(MenuDirectionOptions)direction options:(NSArray *)options optionImages:(NSArray *)optionImages{

    if (self = [super init]) {
        // Assign the parameter values to the appropriate properties.
        self.menuFrame = frame;
        self.targetView = targetView;
        self.menuDirection = direction;
        self.menuOptions = [NSArray arrayWithArray:options];
        if (optionImages != nil) {
            self.menuOptionImages = [NSArray arrayWithArray:optionImages];
        }
        
        // Setup the background view.
        [self setupBackgroundView];
        
        // Setup the menu view.
        [self setupMenuView];
        
        // Setup the options table view.
        [self setupOptionsTableView];
        
        // Set the initial table view settings.
        [self setInitialTableViewSettings];
        
        // Setup the swipe gesture recognizer.
        [self setupSwipeGestureRecognizer];
        
        
        // Initialize the animator.
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.targetView];
        
        // Set the initial height for each cell row.
        self.optionCellHeight = 50.0;
        
        // Set the initial acceleration value (push magnitude).
        self.acceleration = 15.0;
        
        // Indicate that initially the menu is not shown.
        self.isMenuShown = NO;
    }
        return self;
}


#pragma mark - Private method implementation
    
-(void)setupMenuView{
    if (self.menuDirection == menuDirectionLeftToRight) {
        self.menuInitialFrame = CGRectMake(-self.menuFrame.size.width,
                                           self.menuFrame.origin.y,
                                           self.menuFrame.size.width,
                                           self.menuFrame.size.height);
    }
    else{
        self.menuInitialFrame = CGRectMake(self.targetView.frame.size.width,
                                           self.menuFrame.origin.y,
                                           self.menuFrame.size.width,
                                           self.menuFrame.size.height);
    }
    
    self.menuView = [[UIView alloc] initWithFrame:self.menuInitialFrame];
    [self.menuView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.47 blue:0.39 alpha:1.0]];
    [self.targetView addSubview:self.menuView];
}



-(void)setupBackgroundView{
    self.backgroundView = [[UIView alloc] initWithFrame:self.targetView.frame];
    [self.backgroundView setBackgroundColor:[UIColor grayColor]];
    [self.backgroundView setAlpha:0.0];
    [self.targetView addSubview:self.backgroundView];
}


-(void)setupOptionsTableView{
    self.optionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.menuFrame.size.width, self.menuFrame.size.height) style:UITableViewStylePlain];
    [self.optionsTableView setBackgroundColor:[UIColor clearColor]];
    [self.optionsTableView setScrollEnabled:NO];
    [self.optionsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.menuView addSubview:self.optionsTableView];
    
    [self.optionsTableView setDelegate:self];
    [self.optionsTableView setDataSource:self];
}


-(void)setInitialTableViewSettings{
    self.tableSettings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          [UIFont fontWithName:@"American Typewriter" size:15.0], @"font",
                          [NSNumber numberWithInt:NSTextAlignmentLeft], @"textAlignment",
                          [UIColor whiteColor], @"textColor",
                          [NSNumber numberWithInt:UITableViewCellSelectionStyleGray], @"selectionStyle",
                          nil];
}


-(void)setupSwipeGestureRecognizer{
    UISwipeGestureRecognizer *hideMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenuWithGesture:)];
    if (self.menuDirection == menuDirectionLeftToRight) {
        hideMenuGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    else{
        hideMenuGesture.direction = UISwipeGestureRecognizerDirectionRight;
    }
    [self.menuView addGestureRecognizer:hideMenuGesture];
}


-(void)toggleMenu{
    // Remove any previous behaviors added to the animator.
    [self.animator removeAllBehaviors];
    
    // The following variables will define the direction of the menu view movement.
    
    // This variable indicates the gravity direction.
    CGFloat gravityDirectionX;
    
    // These two points specify an invisible boundary where the menu view should collide.
    // The boundary must be always to the side of the gravity direction so as the menu view
    // can stop moving.
    CGPoint collisionPointFrom, collisionPointTo;
    
    // The higher the push magnitude value, the greater the acceleration of the menu view.
    // If that value is set to 0.0, then only the gravity force will be applied to the
    // menu view.
    CGFloat pushMagnitude = self.acceleration;
    
    // Check if the menu is shown or not.
    if (!self.isMenuShown) {
        // If the menu view is hidden and it's about to be shown, then specify each variable
        // value depending on the animation direction.
        if (self.menuDirection == menuDirectionLeftToRight) {
            // The value 1.0 means that gravity “moves” the view towards the right side.
            gravityDirectionX = 1.0;
            
            // The From and To points define an invisible boundary, where the X-origin point
            // equals to the desired X-origin point that the menu view should collide, and the
            // Y-origin points specify the highest and lowest point of the boundary.
            
            // If the menu view is being shown from left to right, then the collision boundary
            // should be defined so as to be at the right of the initial menu view position.
            collisionPointFrom = CGPointMake(self.menuFrame.size.width, self.menuFrame.origin.y);
            collisionPointTo = CGPointMake(self.menuFrame.size.width, self.menuFrame.size.height);
        }
        else{
            // The value -1.0 means that gravity "pulls" the view towards the left side.
            gravityDirectionX = -1.0;
            
            // If the menu view is being shown from right to left, then the collision boundary
            // should be defined so as to be at the left of the initial menu view position.
            collisionPointFrom = CGPointMake(self.targetView.frame.size.width - self.menuFrame.size.width, self.menuFrame.origin.y);
            collisionPointTo = CGPointMake(self.targetView.frame.size.width - self.menuFrame.size.width, self.menuFrame.size.height);
            
            // Set to the pushMagnitude variable the opposite value.
            pushMagnitude = (-1) * pushMagnitude;
        }
        
        // Make the background view semi-transparent.
        [self.backgroundView setAlpha:0.25];
    }
    else{
        // In case the menu is about to be hidden, then the exact opposite values should be
        // set to all variables for succeeding the opposite animation.
        
        if (self.menuDirection == menuDirectionLeftToRight) {
            gravityDirectionX = -1.0;
            collisionPointFrom = CGPointMake(-self.menuFrame.size.width, self.menuFrame.origin.y);
            collisionPointTo = CGPointMake(-self.menuFrame.size.width, self.menuFrame.size.height);
            
            // Set to the pushMagnitude variable the opposite value.
            pushMagnitude = (-1) * pushMagnitude;
        }
        else{
            gravityDirectionX = 1.0;
            collisionPointFrom = CGPointMake(self.targetView.frame.size.width + self.menuFrame.size.width, self.menuFrame.origin.y);
            collisionPointTo = CGPointMake(self.targetView.frame.size.width + self.menuFrame.size.width, self.menuFrame.size.height);
        }
        
        // Make the background view fully transparent.
        [self.backgroundView setAlpha:0.0];
    }
    
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.menuView]];
    [gravityBehavior setGravityDirection:CGVectorMake(gravityDirectionX, 0.0)];
    [self.animator addBehavior:gravityBehavior];
    
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.menuView]];
    [collisionBehavior addBoundaryWithIdentifier:@"collisionBoundary"
                                       fromPoint:collisionPointFrom
                                         toPoint:collisionPointTo];
    [self.animator addBehavior:collisionBehavior];
    
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.menuView]];
    [itemBehavior setElasticity:0.35];
    [self.animator addBehavior:itemBehavior];
    
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.menuView] mode:UIPushBehaviorModeInstantaneous];
    [pushBehavior setMagnitude:pushMagnitude];
    [self.animator addBehavior:pushBehavior];
}


-(void)hideMenuWithGesture:(UISwipeGestureRecognizer *)gesture{
    // Make a call to toggleMenu method for hiding the menu.
    [self toggleMenu];
    
    // Indicate that the menu is not shown.
    self.isMenuShown = NO;
}

#pragma mark - Public method implementation

-(void)showMenuWithSelectionHandler:(void (^)(NSInteger))handler{
    if (!self.isMenuShown) {
        self.selectionHandler = handler;
        
        [self toggleMenu];
        
        self.isMenuShown = YES;
    }
}


#pragma mark - TableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.menuOptions count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.optionCellHeight;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"optionCell"];
    }
    
    // Set the selection style.
    [cell setSelectionStyle:[[self.tableSettings objectForKey:@"selectionStyle"] intValue]];
    
    // Set the cell's text and specify various properties of it.
    cell.textLabel.text = [self.menuOptions objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[self.tableSettings objectForKey:@"font"]];
    [cell.textLabel setTextAlignment:[[self.tableSettings objectForKey:@"textAlignment"] intValue]];
    [cell.textLabel setTextColor:[self.tableSettings objectForKey:@"textColor"]];
    
    // If the menu option images array is not nil, then set the cell image.
    if (self.menuOptionImages != nil) {
        [cell.imageView setImage:[UIImage imageNamed:[self.menuOptionImages objectAtIndex:indexPath.row]]];
        [cell.imageView setTintColor:[UIColor whiteColor]];
    }
    
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    self.selectionHandler(indexPath.row);
}


@end
