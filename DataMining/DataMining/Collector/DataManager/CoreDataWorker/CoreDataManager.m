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

@property (nonatomic,weak)NSManagedObjectContext* managedObjectContext;

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
                    strName = kDeviceMotion_Temp;
                else
                    strName = kDeviceMotion;
                [self.managedObjectContext tryLock];
                DeviceMotion* deviceMotion = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [self.managedObjectContext unlock];
                [deviceMotion setDataWithDict:dict];
            }
                break;
            case entitiesType_Location: {
                if (isTemp)
                    strName = kLocation_Temp;
                else
                    strName = kLocation;
                [self.managedObjectContext tryLock];
                Location* location = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [self.managedObjectContext unlock];
                [location setDataWithDict:dict];
            }
                break;
            case entitiesType_Touch: {
                if (isTemp)
                    strName = kTouch_Temp;
                else
                    strName = kTouch;
                [self.managedObjectContext tryLock];
                Touch* touch = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [self.managedObjectContext unlock];
                [touch setDataWithDict:dict];
            }
                break;
            case entitiesType_Accelerometer: {
                if (isTemp)
                    strName = kAccelerometer_Temp;
                else
                    strName = kAccelerometer;
                [self.managedObjectContext tryLock];
                Accelerometer* accelerometer = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [self.managedObjectContext unlock];
                [accelerometer setDataWithDict:dict];
            }
                break;
            case entitiesType_Health: {
                if (isTemp)
                    strName = kHealth_Temp;
                else
                    strName = kHealth;
                [self.managedObjectContext tryLock];
                Health* health = [NSEntityDescription insertNewObjectForEntityForName:strName inManagedObjectContext:_managedObjectContext];
                [self.managedObjectContext unlock];
                [health setDataWithDict:dict];
            }
                break;
        }
        //NSError* error = nil;
        //return [_managedObjectContext save:&error];
        return YES;
    }
}

- (BOOL)saveData {
    NSError* error = nil;
    return [_managedObjectContext save:&error];
}

- (BOOL)addEntities:(entitiesType)type WithData:(NSDictionary*)dict {
    return [self addData:type Data:dict isTemp:NO];
}

- (NSArray*)getData:(entitiesType)type count:(NSUInteger)count isTemp:(BOOL)isTemp {
    @synchronized(self) {
        NSMutableArray* array = [[NSMutableArray alloc]initWithCapacity:1];
        NSString* entityName = [self entityNameStringFromType:type isTemp:isTemp];
        NSError* error = nil;
        [self.managedObjectContext tryLock];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:_managedObjectContext];
        if (!entity) {
            [self.managedObjectContext unlock];
            return nil;
        }
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        [self.managedObjectContext unlock];
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

- (NSArray*)getEntitiesData:(entitiesType)type WithCount:(NSUInteger)count {
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
                entityName = kDeviceMotion_Temp;
            else
                entityName = kDeviceMotion;
            break;
        case entitiesType_Location:
            if (isTemp)
                entityName = kLocation_Temp;
            else
                entityName = kLocation;
            break;
        case entitiesType_Touch:
            if (isTemp)
                entityName = kTouch_Temp;
            else
                entityName = kTouch;
            break;
        case entitiesType_Accelerometer:
            if (isTemp)
                entityName = kAccelerometer_Temp;
            else
                entityName = kAccelerometer;
            break;
        case entitiesType_Health:
            if (isTemp)
                entityName = kHealth_Temp;
            else
                entityName = kHealth;
            break;
    }
    
    return entityName;
}

- (void)deleteData:(entitiesType)type count:(NSUInteger)count isTemp:(BOOL)isTemp {
    @synchronized(self) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSString* entityName = [self entityNameStringFromType:type isTemp:isTemp];
        [self.managedObjectContext tryLock];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext];
        if (!entity) {
            [self.managedObjectContext unlock];
            return;
        }
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        [self.managedObjectContext unlock];
        for (NSManagedObject *info in fetchedObjects) {
            @autoreleasepool {
                //if (!isTemp) {
                if (count == 0)
                    break;
                //}
                [_managedObjectContext deleteObject:info];
                //if (!isTemp)
                count--;
            }
        }
        //[_managedObjectContext save:&error];
    }
}

- (NSUInteger)getTotalCount:(entitiesType)type isTemp:(BOOL)isTemp {
    @synchronized(self) {
        NSString* entityName = [self entityNameStringFromType:type isTemp:isTemp];
        NSError* error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [self.managedObjectContext tryLock];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:_managedObjectContext];
        if (!entity) {
            [self.managedObjectContext unlock];
            return 0;
        }
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        [self.managedObjectContext unlock];
        return fetchedObjects.count;
    }
}

- (void)deleteEntities:(entitiesType)type WithCount:(NSUInteger)count {
    [self deleteData:type count:count isTemp:NO];
}

- (BOOL)addEntities_Temp:(entitiesType)type WithData:(NSDictionary*)dict {
    return [self addData:type Data:dict isTemp:YES];
}

- (NSArray*)getEntitiesData_Temp:(entitiesType)type {
    return [self getData:type count:0 isTemp:YES];
}

- (void)deleteEntities_Temp:(entitiesType)type WithCount:(NSUInteger)count {
    [self deleteData:type count:count isTemp:YES];
}

@end
