//
//  MMOpenInShareItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMShareItem.h"
#import "MMShareViewDelegate.h"
#import "MMShareManagerDelegate.h"

@interface MMOpenInShareItem : NSObject<MMShareItem,MMShareViewDelegate,MMShareManagerDelegate>

-(UIView*) optionsView;



@end
