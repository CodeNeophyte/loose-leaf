//
//  NSURL+UTI.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (UTI)

-(NSString*) universalTypeID;

-(NSString*) fileExtension;

@end