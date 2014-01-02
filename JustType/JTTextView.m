//
//  JTTextView.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "JTTextView.h"
#import "JTTextViewMediatorDelegate.h"
#import "JTKeyboardAttachmentView.h"
#import "NSString+JTExtension.h"
#import "JTDashedBorderedView.h"

@interface JTTextView ()

@property (nonatomic, retain) JTTextController *textController;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *pressGesture;

@property (nonatomic, assign) id<UITextViewDelegate> actualDelegate;
@property (nonatomic, retain) JTTextViewMediatorDelegate *mediatorDelegate;
@property (nonatomic, retain) UIView *highlightView;

@property (nonatomic, assign) BOOL isIgnoringUpdates;

@end


@implementation JTTextView
@synthesize textController = _textController;
@synthesize tapGesture = _tapGesture;
@synthesize pressGesture = _pressGesture;

@synthesize actualDelegate = _actualDelegate;
@synthesize mediatorDelegate = _mediatorDelegate;
@synthesize isIgnoringUpdates = _isIgnoringUpdates;
@synthesize highlightView = _highlightView;

#pragma mark - Object lifecycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;

        _textController = [[JTTextController alloc] init];
        _textController.delegate = self;
        
        _mediatorDelegate = [[JTTextViewMediatorDelegate alloc] init];
        _mediatorDelegate.textView = self;
        [super setDelegate:_mediatorDelegate];
                
        self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        
        JTDashedBorderedView *highlightView = [[JTDashedBorderedView alloc] initWithFrame:CGRectZero];
        highlightView.backgroundColor = [UIColor clearColor];
        highlightView.userInteractionEnabled = NO;
        [self addSubview:highlightView];
        self.highlightView = highlightView;
    }
    return self;
}

- (void)dealloc {
    _mediatorDelegate = nil;
    _textController.delegate = nil;
    _textController = nil;
}

#pragma mark - text controller delegate actions
- (NSString *)textContent {
    return self.text;
}

- (void)replaceHighlightingWithRange:(NSRange)newRange {
    CGRect highlightRect = [self firstRectForRange:[self.textController textRangeFromRange:newRange]];
    highlightRect.origin.x -= 2;
    highlightRect.size.width += 4;
    self.highlightView.frame = highlightRect;
    [self.highlightView setNeedsDisplay];
}

#pragma mark - Overwritten methods
- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    [super setInputAccessoryView:inputAccessoryView];
    if ([inputAccessoryView isKindOfClass:[JTKeyboardAttachmentView class]]) {
        self.textController.keyboardAttachmentView = (JTKeyboardAttachmentView *)inputAccessoryView;
    }
}

#pragma mark - Actions forwarded to controller
- (void)didChangeText {
    [self.textController didChangeText];
}

- (void)didChangeSelection {
    [self.textController didChangeSelection];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.textController didChangeText];
    });
    return YES;
}

#pragma mark - overwritten methods
- (id<UITextViewDelegate>)delegate {
    return self.mediatorDelegate;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    self.actualDelegate = delegate;
}

@end


