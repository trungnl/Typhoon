////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2013, Jasper Blues & Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import <SenTestingKit/SenTestingKit.h>
#import "Typhoon.h"
#import "Knight.h"

NSUInteger currentDamselsRescued;
BOOL currentHasHorseWillTravel;
NSString *currentFooString;


@interface ClassWithKnightSettings : NSObject
@property(nonatomic) NSUInteger damselsRescued;
@property(nonatomic) BOOL hasHorseWillTravel;
@property(nonatomic) NSString *fooString;
@end

@implementation ClassWithKnightSettings
@end

@interface ClassWithKnightSettingsAssembly : TyphoonAssembly
@end

@implementation ClassWithKnightSettingsAssembly

- (id)knightSettings
{
    return [TyphoonDefinition withClass:[ClassWithKnightSettings class] properties:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(damselsRescued) withObjectInstance:@(currentDamselsRescued)];
        [definition injectProperty:@selector(hasHorseWillTravel) withObjectInstance:@(currentHasHorseWillTravel)];
        [definition injectProperty:@selector(fooString) withObjectInstance:currentFooString];
    }];
}

@end


@interface FactoryReferenceInjectionsTests : SenTestCase

@end


@implementation FactoryReferenceInjectionsTests
{
    TyphoonComponentFactory *factory;
}

- (void)setUp
{
    [self updateFactory];
}

- (void)updateFactory
{
    factory = [TyphoonBlockComponentFactory factoryWithAssembly:[ClassWithKnightSettingsAssembly assembly]];
}

- (void)test_inject_int_bool
{
    Knight *knight = [Knight new];

    TyphoonDefinition *knightDefinition = [TyphoonDefinition withClass:[Knight class] properties:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(damselsRescued) withObjectInstance:@(30)];
        [definition injectProperty:@selector(hasHorseWillTravel) withObjectInstance:@(YES)];
    }];

    [factory doPropertyInjectionEventsOn:(id) knight withDefinition:knightDefinition];

    assertThatInteger(knight.damselsRescued, equalToInteger(30));
    assertThatBool(knight.hasHorseWillTravel, equalToBool(YES));
}

- (void)test_inject_object
{
    Knight *knight = [Knight new];

    NSString *testString = @"Hello Knights";

    TyphoonDefinition *knightDefinition = [TyphoonDefinition withClass:[Knight class] properties:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(foobar) withObjectInstance:testString];
    }];
    [factory doPropertyInjectionEventsOn:(id) knight withDefinition:knightDefinition];

    assertThat(knight.foobar, equalTo([testString copy]));
}

- (void)test_inject_factorydefinition_selector
{
    Knight *knight = [Knight new];

    currentFooString = @"Hello Knights";
    currentDamselsRescued = 24;
    currentHasHorseWillTravel = YES;
    [self updateFactory];

    TyphoonDefinition *settings = [factory definitionForType:[ClassWithKnightSettings class]];

    TyphoonDefinition *knightDefinition = [TyphoonDefinition withClass:[Knight class] properties:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(damselsRescued) withDefinition:settings selector:@selector(damselsRescued)];
        [definition injectProperty:@selector(hasHorseWillTravel) withDefinition:settings selector:@selector(hasHorseWillTravel)];
        [definition injectProperty:@selector(foobar) withDefinition:settings selector:@selector(fooString)];
    }];
    [factory doPropertyInjectionEventsOn:(id) knight withDefinition:knightDefinition];

    assertThat(knight.foobar, equalTo(@"Hello Knights"));
    assertThatInteger(knight.damselsRescued, equalToInteger(24));
    assertThatBool(knight.hasHorseWillTravel, equalToBool(YES));
}

- (void)test_inject_factorydefinition_keyPath
{
    Knight *knight = [Knight new];

    NSString *testString = @"Hello";
    currentFooString = [testString copy];
    [self updateFactory];

    TyphoonDefinition *settings = [factory definitionForType:[ClassWithKnightSettings class]];

    TyphoonDefinition *knightDefinition = [TyphoonDefinition withClass:[Knight class] properties:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(foobar) withDefinition:settings keyPath:@"fooString.uppercaseString"];
    }];
    [factory doPropertyInjectionEventsOn:(id) knight withDefinition:knightDefinition];

    assertThat(knight.foobar, equalTo(@"HELLO"));
}


- (void)test_inject_factorydefinition_on_init
{
    currentDamselsRescued = 32;
    currentFooString = @"Hello";
    [self updateFactory];

    TyphoonDefinition *settings = [factory definitionForType:[ClassWithKnightSettings class]];

    TyphoonDefinition *knightDefinition = [TyphoonDefinition withClass:[Knight class] initialization:^(TyphoonInitializer *initializer) {
        [initializer setSelector:@selector(initWithDamselsRescued:foo:)];
        [initializer injectWithDefinition:settings selector:@selector(damselsRescued)];
        [initializer injectWithDefinition:settings keyPath:@"fooString.uppercaseString"];
    }];

    [factory registerDefinition:knightDefinition];

    Knight *knight = [factory componentForType:[Knight class]];

    assertThatInteger(knight.damselsRescued, equalToInteger(32));
    assertThat(knight.foobar, equalTo(@"HELLO"));

}


@end
