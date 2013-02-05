//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Jason Williamson on 2013-01-13.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushVariable:(NSString *)operand;
- (void)pushOperation:(NSString *)operation;
- (void)clearOperandStack;
- (void)removeLastItemFromStack;

// program is always guaranteed to be a Property List
@property (readonly) id program;

+ (id)runProgram:(id)program;
+ (id)runProgram:(id)program
      usingVariables:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
