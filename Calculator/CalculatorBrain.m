//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Jason Williamson on 2013-01-13.
//  Copyright (c) 2013 Jason Williamson. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

+ (BOOL)isOperation:(NSString *)operation;

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

-(void)clearOperandStack
{
    [self.programStack removeAllObjects];
}

-(void)removeLastItemFromStack
{
    [self.programStack removeLastObject];
}

-(void)pushOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
}

-(id)program
{
    return [self.programStack copy];
}

+ (BOOL)isOperation:(NSString *)item
{
    NSSet *operationSet = [NSSet setWithObjects:@"+", @"*", @"-", @"/",
                           @"sin", @"cos", @"sqrt",@"+/-",@"π", nil];
    return [operationSet containsObject:item];
}

+ (BOOL)isVariable:(NSString *)item
{
    NSSet *variableSet = [NSSet setWithObjects:@"x", nil];
    return [variableSet containsObject:item];
}

+ (BOOL)isNoOperandOperation:(NSString *)operation
{
    NSSet *noOperandOperationSet = [NSSet setWithObjects:@"π", nil];
    return [noOperandOperationSet containsObject:operation];
}

+(BOOL)isSingleOperandOperation:(NSString *)operation
{
    NSSet *operationSet = [NSSet setWithObjects:@"sin", @"cos", @"sqrt", nil];
    return [operationSet containsObject:operation];
}

+(BOOL)isDoubleOperandOperation:(NSString *)operation
{
    NSSet *operationSet = [NSSet setWithObjects:@"+", @"*", @"-", @"/", nil];
    return [operationSet containsObject:operation];
}

+(NSString *)removeOuterBracket:(NSString *)description
{
    NSString *newDescription = description;
    if ([description hasPrefix:@"("]) {
        newDescription = [description substringWithRange:NSMakeRange(1, [description length]-2)];
    }
    
    return newDescription;
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *description;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        description = [topOfStack description];
    } else if ([self isOperation:topOfStack ]) {
        if ([self isNoOperandOperation:topOfStack]) {
            description = topOfStack;
        }else if ([self isSingleOperandOperation:topOfStack]){
            NSString *value = [self descriptionOfTopOfStack:stack];
            value = [self removeOuterBracket:value];
            description = [NSString stringWithFormat:@"%@(%@)", topOfStack,value];
        }else if ([self isDoubleOperandOperation:topOfStack]){
            NSString *v1 = [self descriptionOfTopOfStack:stack];
            NSString *v2 = [self descriptionOfTopOfStack:stack];
            description = [NSString stringWithFormat:@"(%@ %@ %@)",v2, topOfStack, v1];
        }
        
    } else if ([self isVariable:topOfStack]){
         description = topOfStack;
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSMutableArray *descriptionArray = [NSMutableArray array];
    
       
    while ([stack count]) {
        [descriptionArray addObject:[self removeOuterBracket:[self descriptionOfTopOfStack:stack]]];
    }
    
    return [descriptionArray componentsJoinedByString:@","];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSMutableSet *usedVariables = [[NSMutableSet alloc] init];
    for (int i = 0;i < [stack count]; i++) {
        id obj = [stack objectAtIndex:i];
        if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj]) {
            NSString *variable = obj;
            [usedVariables addObject:variable];
        }
    }
    
    if ([usedVariables count]) {
        return usedVariables;
    }
    return nil;
    
}

+ (id)popOperandOffStack:(NSMutableArray *)stack
{
    id result;
    double operandValue1 = 0, operandValue2 = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = topOfStack;
    }
    else if ([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        
        if([self isNoOperandOperation:operation]){
            if([operation isEqualToString:@"π"]) result = [NSNumber numberWithDouble:M_1_PI];
        }else if([self isSingleOperandOperation:operation]){
            id operand = [self popOperandOffStack:stack];
            if(![operand isKindOfClass:[NSNumber class]]){
                result = @"Error: insufficient operands";
            }else{
                operandValue1 = [operand doubleValue];
                if([operation isEqualToString:@"sin"]){
                    result = [NSNumber numberWithDouble:sin(operandValue1)];
                }else if ([operation isEqualToString:@"cos"]){
                    result = [NSNumber numberWithDouble:cos(operandValue1)];
                }else if ([operation isEqualToString:@"sqrt"]){
                    if(operandValue1 >= 0){
                        result = [NSNumber numberWithDouble:sqrt(operandValue1)];
                    }else{
                        result = @"Error: sqrt of negative";
                    }
                }else if ([operation isEqualToString:@"+/-"]){
                    result = [NSNumber numberWithDouble:operandValue1 * -1];
                }
            }
        }else if([self isDoubleOperandOperation:operation]){
            id operand1 = [self popOperandOffStack:stack];
            id operand2 = [self popOperandOffStack:stack];
            if(![operand1 isKindOfClass:[NSNumber class]] || ![operand2 isKindOfClass:[NSNumber class]]){
                result = @"Error: insufficient operands";
            }else{
                operandValue1 = [operand1 doubleValue];
                operandValue2 = [operand2 doubleValue];
                if ([operation isEqualToString:@"+"]){
                    result = [NSNumber numberWithDouble:operandValue1 + operandValue2];
                } else if ([@"*" isEqualToString:operation]){
                    result = [NSNumber numberWithDouble:operandValue1 * operandValue2];
                } else if ([operation isEqualToString:@"-"]){
                    result = [NSNumber numberWithDouble:operandValue2 - operandValue1];
                } else if ([operation isEqualToString:@"/"]){
                    if(operandValue1 != 0){
                        result = [NSNumber numberWithDouble:operandValue2 / operandValue1];
                    }else{
                        result = @"Error: divide by 0";
                    }
                }
            }
        }else{
            result = @"Error: entry not supported";
        }
    }
    return result;
}

+ (id)runProgram:(id)program
{
    return [self runProgram:program usingVariables:nil];
}

+ (id)runProgram:(id)program usingVariables:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    for (int i = 0; i < [stack count]; i++) {
        id obj = [stack objectAtIndex:i];
        if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj]) {
            NSString *variable = obj;
            id value = [variableValues objectForKey:variable];
            if( ![value isKindOfClass:[NSNumber class]]){
                value = [NSNumber numberWithDouble:0];
            }
            [stack replaceObjectAtIndex:i withObject:value];
        }
    }
    
    
    return [self popOperandOffStack:stack];
}


@end
