//
//  MenuComponent.h
//  DynamicsDemo
//
//  Created by Gabriel Theodoropoulos on 31/3/14.
//  Copyright (c) 2014 Gabriel Theodoropoulos. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum MenuDirectionOptionTypes{
    menuDirectionLeftToRight,
    menuDirectionRightToLeft
} MenuDirectionOptions;


@interface MenuComponent : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIColor *menuBackgroundColor;

@property (nonatomic, strong) NSMutableDictionary *tableSettings;

@property (nonatomic) CGFloat optionCellHeight;

@property (nonatomic) CGFloat acceleration;


-(id)initMenuWithFrame:(CGRect)frame targetView:(UIView *)targetView direction:(MenuDirectionOptions)direction options:(NSArray *)options optionImages:(NSArray *)optionImages;

-(void)showMenuWithSelectionHandler:(void(^)(NSInteger selectedOptionIndex))handler;

@end
