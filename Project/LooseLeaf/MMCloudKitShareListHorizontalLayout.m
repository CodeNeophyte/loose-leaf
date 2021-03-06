//
//  MMCloudKitShareListHorizontalLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitShareListHorizontalLayout.h"
#import "Constants.h"


@implementation MMCloudKitShareListHorizontalLayout {
    UICollectionViewLayout* previousLayout;
    BOOL shouldFlip;
}

- (id)initWithFlip:(BOOL)_shouldFlip {
    if (self = [super init]) {
        shouldFlip = _shouldFlip;
    }
    return self;
}

- (CGFloat)buttonWidth {
    return self.collectionView.bounds.size.width / 4;
}

- (NSInteger)entireRowCount {
    NSInteger ret = 0;
    for (int section = 0; section < [self.collectionView numberOfSections]; section++) {
        ret += [self.collectionView numberOfItemsInSection:section];
    }
    return ret;
}

- (CGSize)collectionViewContentSize {
    NSInteger numItems = [self entireRowCount] + 1; // invite button is two items tall
    int offset = 4 - numItems % 4;
    if (offset == 4)
        offset = 0;
    numItems += offset;
    return CGSizeMake(self.collectionView.bounds.size.width - 2 * kWidthOfSidebarButtonBuffer, numItems * [self buttonWidth]);
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewLayoutAttributes* ret = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    BOOL isLastCell = indexPath.section == [self.collectionView numberOfSections] - 1 &&
        indexPath.row == [self.collectionView numberOfItemsInSection:indexPath.section] - 1;

    NSInteger numRowsInPrevSections = 0;
    for (int i = 0; i < indexPath.section; i++) {
        numRowsInPrevSections += [self.collectionView numberOfItemsInSection:i];
    }
    NSInteger trueIndexInList = numRowsInPrevSections + indexPath.row;
    int transformIndex = trueIndexInList % 4; // 4 cells rotate together

    if (isLastCell && transformIndex == 3) {
        // if our invite button is at the bottom
        // of the 4 cell group, then push it
        // into the next group
        trueIndexInList += 1;
        transformIndex = 0;
    }

    CGFloat contactHeight = [self buttonWidth];
    CGFloat cellHeight = isLastCell ? 150.0 : contactHeight;
    CGFloat width = self.collectionView.bounds.size.width - 2 * kWidthOfSidebarButtonBuffer;
    ret.bounds = CGRectMake(0, 0, width, cellHeight);
    ret.center = CGPointMake(width / 2, trueIndexInList * contactHeight + cellHeight / 2);

    CGPoint translate;
    if (shouldFlip) {
        if (transformIndex == 0) {
            translate = CGPointMake(+1.5 * [self buttonWidth], +1.5 * [self buttonWidth]);
        } else if (transformIndex == 1) {
            translate = CGPointMake(+0.5 * [self buttonWidth], +0.5 * [self buttonWidth]);
        } else if (transformIndex == 2) {
            translate = CGPointMake(-0.5 * [self buttonWidth], -0.5 * [self buttonWidth]);
        } else {
            translate = CGPointMake(-1.5 * [self buttonWidth], -1.5 * [self buttonWidth]);
        }
        if (isLastCell) {
            if (transformIndex == 0) {
                translate = CGPointMake(+1.0 * [self buttonWidth], +1.0 * [self buttonWidth]);
            } else if (transformIndex == 1) {
                translate = CGPointMake(+0.0 * [self buttonWidth], +0.0 * [self buttonWidth]);
            } else if (transformIndex == 2) {
                translate = CGPointMake(-1.0 * [self buttonWidth], -1.0 * [self buttonWidth]);
            }
        }
        ret.transform = CGAffineTransformMakeRotation(M_PI_2);
    } else {
        if (transformIndex == 0) {
            translate = CGPointMake(-1.5 * [self buttonWidth], +1.5 * [self buttonWidth]);
        } else if (transformIndex == 1) {
            translate = CGPointMake(-0.5 * [self buttonWidth], +0.5 * [self buttonWidth]);
        } else if (transformIndex == 2) {
            translate = CGPointMake(+0.5 * [self buttonWidth], -0.5 * [self buttonWidth]);
        } else {
            translate = CGPointMake(+1.5 * [self buttonWidth], -1.5 * [self buttonWidth]);
        }
        if (isLastCell) {
            if (transformIndex == 0) {
                translate = CGPointMake(-1.0 * [self buttonWidth], +1.0 * [self buttonWidth]);
            } else if (transformIndex == 1) {
                translate = CGPointMake(+0.0 * [self buttonWidth], +0.0 * [self buttonWidth]);
            } else if (transformIndex == 2) {
                translate = CGPointMake(+1.0 * [self buttonWidth], -1.0 * [self buttonWidth]);
            }
        }
        ret.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    ret.center = CGPointMake(ret.center.x + translate.x + kWidthOfSidebarButtonBuffer, ret.center.y + translate.y);
    return ret;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger firstIndex = floorf(rect.origin.y / [self buttonWidth]);
    NSInteger lastIndex = floorf((rect.origin.y + rect.size.height) / [self buttonWidth]);
    // round to sections of 4
    firstIndex -= firstIndex % 4;
    lastIndex += 4 - lastIndex % 4;

    NSInteger totalCount = 0;
    NSMutableArray* attrs = [NSMutableArray array];
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        for (NSInteger index = 0; index < [self.collectionView numberOfItemsInSection:section]; index++) {
            if (totalCount >= firstIndex && totalCount <= lastIndex) {
                [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]]];
            }
            totalCount++;
        }
    }
    return attrs;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    return self.collectionView.contentOffset.y == 0 ? self.collectionView.contentOffset : proposedContentOffset;
}

- (void)prepareForTransitionFromLayout:(UICollectionViewLayout*)oldLayout {
    // save our previous layout so that
    // we can animate from it as we come into view
    previousLayout = oldLayout;
}

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath*)itemIndexPath {
    if (previousLayout) {
        return [previousLayout layoutAttributesForItemAtIndexPath:itemIndexPath];
    } else {
        return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    }
}

- (UICollectionViewLayoutAttributes*)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath*)itemIndexPath {
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

@end
