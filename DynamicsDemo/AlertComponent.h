//
//  AlertComponent.h
//  DynamicsDemo
//
//  Created by Gabriel Theodoropoulos on 31/3/14.
//  Copyright (c) 2014 Gabriel Theodoropoulos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertComponent : NSObject

-(id)initAlertWithTitle:(NSString *)title andMessage:(NSString *)message andButtonTitles:(NSArray *)buttonTitles andTargetView:(UIView *)targetView;

-(void)showAlertViewWithSelectionHandler:(void(^)(NSInteger buttonIndex, NSString *buttonTitle))handler;

@end
