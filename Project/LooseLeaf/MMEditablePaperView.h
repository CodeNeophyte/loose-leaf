//
//  MMEditablePaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperView.h"
#import <JotUI/JotUI.h>
#import <TouchShape/TouchShape.h>
#import "MMRulerToolGestureRecognizer.h"
#import "MMPolygonDebugView.h"

@interface MMEditablePaperView : MMPaperView<JotViewDelegate>{
    UIImageView* cachedImgView;
    __weak JotView* drawableView;
    MMPolygonDebugView* polygonDebugView;
    
    MMRulerToolGestureRecognizer* rulerGesture;
}

@property (nonatomic, weak) JotView* drawableView;

-(void) undo;
-(void) redo;
-(BOOL) hasEditsToSave;
-(void) unloadCachedPreview;
-(void) loadCachedPreview;
-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize) pagePixelSize andContext:(JotGLContext*)context andThen:(void (^)())block;
-(void) unloadState;
-(void) saveToDisk;
-(void) setCanvasVisible:(BOOL)isVisible;
-(void) setEditable:(BOOL)isEditable;



@end
