//
//  CoreDataManager.m
//  DataMining
//
//  Created by liuxu on 16/1/22.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "DeviceMotion.h"
#import "Location.h"
#import "Touch.h"
#import "Accelerometer.h"
#import "Health.h"

@interface CoreDataManager()

@property (nonatomic,strong)NSManagedObjectContext* managedObjectContext;

@end

@implementation CoreDataManager

+ (CoreDataManager*)shareInstance {
    static CoreDataManager* mgr = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        mgr = [[CoreDataManager alloc]init];
        AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
        mgr.managedObjectContext = delegate.managedObjectContext;
    });
    
    return mgr;
}

- (BOOL)addEntities:(entitiesType)type WithData:(NSDictionary*)dict {
    @synchronized(self) {
        switch (type) {
            case entitiesType_DeviceMontion: {
                DeviceMotion* deviceMotion = [NSEntityDescription insertNewObjectForEntityForName:@"DeviceMotion" inManagedObjectContext:_managedObjectContext];
                [deviceMotion setDataWithDict:dict];
            }
                break;
            case entitiesType_Location: {
                Location* location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:_managedObjectContext];
                [location setDataWithDict:dict];
            }
                break;
            case entitiesType_Touch: {
                Touch* touch = [NSEntityDescription insertNewObjectForEntityForName:@"Touch" inManagedObjectContext:_managedObjectContext];
                [touch setDataWithDict:dict];
            }
                break;
            case entitiesType_Accelerometer: {
                Accelerometer* accelerometer = [NSEntityDescription insertNewObjectForEntityForName:@"Accelerometer" inManagedObjectContext:_managedObjectContext];
                [accelerometer setDataWithDict:dict];
            }
                break;
            case entitiesType_Health: {
                Health* health = [NSEntityDescription insertNewObjectForEntityForName:@"Health" inManagedObjectContext:_managedObjectContext];
                [health setDataWithDict:dict];
            }
                break;
        }
        NSError* error = nil;
        return [_managedObjectContext save:&error];
    }
}

- (NSArray*)getEntitiesData:(entitiesType)type WithCount:(int)count {
    @synchronized(self) {
        NSMutableArray* array = [[NSMutableArray alloc]initWithCapacity:1];
        NSString* entityName = [self entityNameStringFromType:type];
        NSError* error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject* obj in fetchedObjects) {
            @autoreleasepool {
                if (count == 0) {
                    break;
                }
                if ([obj respondsToSelector:@selector(getDictionary)]) {
                    NSMutableDictionary* dict = [obj performSelector:@selector(getDictionary) withObject:nil];
                    [array addObject:dict];
                    count--;
                }
            }
        }
        
        return array;
    }
}

- (NSString*)entityNameStringFromType:(entitiesType)type {
    NSString* entityName = nil;
    switch (type) {
        case entitiesType_DeviceMontion:
            entityName = @"DeviceMontion";
            break;
        case entitiesType_Location:
            entityName = @"Location";
            break;
        case entitiesType_Touch:
            entityName = @"Touch";
            break;
        case entitiesType_Accelerometer:
            entityName = @"Accelerometer";
            break;
        case entitiesType_Health:
            entityName = @"Health";
            break;
    }
    
    return entityName;
}

- (void)deleteEntities:(entitiesType)type WithCount:(int)count {
    @synchronized(self) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSString* entityName = [self entityNameStringFromType:type];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *info in fetchedObjects) {
            if (count == 0) {
                break;
            }
            [_managedObjectContext deleteObject:info];
            count--;
        }
        [_managedObjectContext save:&error];
    }
}

@end
