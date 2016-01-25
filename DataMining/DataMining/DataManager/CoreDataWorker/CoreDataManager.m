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

- (BOOL)addData:(entitiesType)type Data:(NSDictionary*)dict isTemp:(BOOL)isTemp {
    @synchronized(self) {
        NSString* strName = nil;
        switch (type) {
            case entitiesType_DeviceMontion: {
                if (isTemp)
                    strName = @"DeviceMotion_Temp";
                else
                    strName = @"DeviceMotion";
                DeviceMotion* deviceMotion = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [deviceMotion setDataWithDict:dict];
            }
                break;
            case entitiesType_Location: {
                if (isTemp)
                    strName = @"Location_Temp";
                else
                    strName = @"Location";
                Location* location = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [location setDataWithDict:dict];
            }
                break;
            case entitiesType_Touch: {
                if (isTemp)
                    strName = @"Touch_Temp";
                else
                    strName = @"Touch";
                Touch* touch = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [touch setDataWithDict:dict];
            }
                break;
            case entitiesType_Accelerometer: {
                if (isTemp)
                    strName = @"Accelerometer_Temp";
                else
                    strName = @"Accelerometer";
                Accelerometer* accelerometer = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [accelerometer setDataWithDict:dict];
            }
                break;
            case entitiesType_Health: {
                if (isTemp)
                    strName = @"Health_Temp";
                else
                    strName = @"Health";
                Health* health = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [health setDataWithDict:dict];
            }
                break;
        }
        NSError* error = nil;
        return [_managedObjectContext save:&error];
    }
}

- (BOOL)addEntities:(entitiesType)type WithData:(NSDictionary*)dict {
    return [self addData:type Data:dict isTemp:NO];
}

- (NSArray*)getData:(entitiesType)type count:(int)count isTemp:(BOOL)isTemp {
    @synchronized(self) {
        NSMutableArray* array = [[NSMutableArray alloc]initWithCapacity:1];
        NSString* entityName = [self entityNameStringFromType:type isTemp:NO];
        NSError* error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject* obj in fetchedObjects) {
            @autoreleasepool {
                if (!isTemp) {
                    if (count <= 0)
                        break;
                }

                if ([obj respondsToSelector:@selector(getDictionary)]) {
                    NSMutableDictionary* dict = [obj performSelector:@selector(getDictionary) withObject:nil];
                    [array addObject:dict];
                    if (!isTemp)
                        count--;
                }
            }
        }
        
        return array;
    }

}

- (NSArray*)getEntitiesData:(entitiesType)type WithCount:(int)count {
    if (count <= 0) {
        return nil;
    }
    return [self getData:type count:count isTemp:NO];
}

- (NSString*)entityNameStringFromType:(entitiesType)type isTemp:(BOOL)isTemp {
    NSString* entityName = nil;
    switch (type) {
        case entitiesType_DeviceMontion:
            if (isTemp)
                entityName = @"DeviceMontion_Temp";
            else
                entityName = @"DeviceMontion";
            break;
        case entitiesType_Location:
            if (isTemp)
                entityName = @"Location_Temp";
            else
                entityName = @"Location";
            break;
        case entitiesType_Touch:
            if (isTemp)
                entityName = @"Touch_Temp";
            else
                entityName = @"Touch";
            break;
        case entitiesType_Accelerometer:
            if (isTemp)
                entityName = @"Accelerometer_Temp";
            else
                entityName = @"Accelerometer";
            break;
        case entitiesType_Health:
            if (isTemp)
                entityName = @"Health_Temp";
            else
                entityName = @"Health";
            break;
    }
    
    return entityName;
}

- (void)deleteData:(entitiesType)type count:(int)count isTemp:(BOOL)isTemp {
    @synchronized(self) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSString* entityName = [self entityNameStringFromType:type isTemp:NO];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *info in fetchedObjects) {
            if (!isTemp) {
                if (count == 0)
                    break;
            }
            [_managedObjectContext deleteObject:info];
            if (!isTemp)
                count--;
        }
        [_managedObjectContext save:&error];
    }
}

- (void)deleteEntities:(entitiesType)type WithCount:(int)count {
    [self deleteData:type count:count isTemp:NO];
}

- (BOOL)addEntities_Temp:(entitiesType)type WithData:(NSDictionary*)dict {
    return [self addData:type Data:dict isTemp:YES];
}

- (NSArray*)getEntitiesData_Temp:(entitiesType)type {
    return [self getData:type count:0 isTemp:YES];
}

- (void)deleteEntities_Temp:(entitiesType)type {
    [self deleteData:type count:0 isTemp:YES];
}

@end
