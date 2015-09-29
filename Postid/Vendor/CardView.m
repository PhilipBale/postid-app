#import "CardView.h"

// Constants Declaration

// This constant represent the distance from the center
// where the action applies. A higher value means that
// the user needs to draw the view further in order for
// the action to be executed.

#define ACTION_MARGIN 120

// This constant is the distance from the center. But vertically

#define Y_ACTION_MARGIN 100


// This constant represent how quickly the view shrinks.
// The view will shrink when is beign moved out the visible
// area.
// A Higher value means slower shrinking

#define SCALE_QUICKNESS 4

// This constant represent how much the view shrinks.
// A Higher value means less shrinking

#define SCALE_MAX .93

// This constant represent the rotation angle

#define ROTATION_ANGLE M_PI / 8

// This constant represent the maximum rotation angle
// allowed in radiands.
// A higher value enables more rotation for the view

#define ROTATION_MAX 1

// This constant defines how fast
// the rotation should be.
// A higher values means a faster rotation.

#define ROTATION_QUICKNESS 320

@interface CardView()

// Internal Variables
@property (nonatomic) CGFloat xFromCenter;

@property (nonatomic) CGFloat yFromCenter;

@property (nonatomic) CGPoint originalPoint;

@end

@implementation CardView

@synthesize state = _state;

- (kCardState) state {
    if (!_state) {
        _state = kCardStateIdle;
    }
    
    return _state;
}

- (void) setState:(kCardState) state {
    
    if (_state != state) {
        _state = state;
        [self.delegate didChangeStateInCard:self];
    }
}

- (kCardPosition) position {
    if (!_position) {
        _position = kCardPositionTop;
    }
    
    return _position;
}

#pragma mark - Init

/*!
 * Designated Initializer
 *
 * This method inits the view
 * and set the feed to fetch
 * also renders the view with feed's data
 *
 * @param CGRect frame for view's bounds
 * @param CardDelegate delegate to send events
 */

- (void) setFrame:(CGRect)frame delegate:(id<CardDelegate>) delegate {
    
    self.frame = frame;
    
    self.delegate = delegate;
    
    [self setupView];
    [self registerSwipeGestures];
}

#pragma mark Init Helper Methods

/*!
 * Round corners of the view
 * and draw a shadow
 * Do another view related
 * actions required on init
 */
- (void) setupView {
    
    // Draw Shadow
    // And round the view
    self.layer.cornerRadius = 10;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1,1);
    
}

/*!
 * Register Pan Gesture
 * and delegates
 */
- (void) registerSwipeGestures {
    
    UIPanGestureRecognizer * panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [self addGestureRecognizer:panRecognizer];
    
}


#pragma mark Pan Gesture Recognizer Handlers

/*!
 * This is the main method for motion detection
 * its called several times a second when the
 * fingers are moved across the screen.
 */
- (void) handlePanGesture: (UIPanGestureRecognizer *) panRecognizer {
    
    // This extracts the coordinate data from the swipe movement.
    // how much did fingers move.
    
    // We need to know the X position.
    // A positive value means movement to the right.
    // A negative value means movement to the left.
    
    self.xFromCenter = [panRecognizer translationInView:self].x;
    
    // We need to know the Y position.
    // A positive value means up movement.
    // A negative value means down movement.
    
    self.yFromCenter = [panRecognizer translationInView:self].y;
    
    // Now we check on wich state our swipe is
    // if is its starting, in the middle or ended
    // the swiping.
    
    switch (panRecognizer.state) {
            
            // Swiping just started
        case UIGestureRecognizerStateBegan: {
            
            // We will save the original point
            // when we started
            self.originalPoint = self.center;
            
            if (self.delegate) {
                
                if ([self.delegate shouldMoveCard:self]) {
                    
                    // And tell the delegate
                    // that the movement just started
                    [self.delegate willBeginSwipeInCard:self];
                    
                }
                
            }
            
            
            break;
        }
            
            // Swiping is in course
        case UIGestureRecognizerStateChanged: {
            
            // Animate the view
            
            if (self.delegate) {
                
                // If delegate is present
                // ask if it should move the card
                if ([self.delegate shouldMoveCard:self]) {
                    
                    [self animateView];
                }
                
            } else {
                [self animateView];
            }
            
            break;
        }
            
            // Swiping ended
        case UIGestureRecognizerStateEnded: {
            
            if (self.delegate) {
                
                if ([self.delegate shouldMoveCard:self]) {
                    
                    [self detectSwipeDirection];
                }
                
            } else {
                [self detectSwipeDirection];
            }
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark Helper Methods

/*!
 * Rotates the view
 * and changes its scale and position
 */
- (void) animateView {
    
    // Do some black magic math
    // for rotating and scale
    
    // Gets the rotation quickness
    // see constants.
    
    CGFloat rotationQuickness = MIN(self.xFromCenter / ROTATION_QUICKNESS, ROTATION_MAX);
    
    // Change the rotation in radians
    CGFloat rotationAngle = (CGFloat) (ROTATION_ANGLE * rotationQuickness);
    
    // the height will change when the view reaches certain point
    CGFloat scale = MAX(1 - fabsf(rotationQuickness) / SCALE_QUICKNESS, SCALE_MAX);
    
    // move the object center depending on the coordinate
    self.center = CGPointMake(self.originalPoint.x + self.xFromCenter,
                              self.originalPoint.y + self.yFromCenter);
    
    
    // rotate by the angle
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(rotationAngle);
    
    // scale depending on the rotation
    CGAffineTransform scaleTransform = CGAffineTransformScale(rotateTransform, scale, scale);
    
    // apply transformations
    self.transform = scaleTransform;
    
    // Change state
    [self changeStateToMoving];
}

/*!
 * With all the values fetched
 * from the pan gesture
 * gets the direction of the swipe
 * when the swipe is done
 */
- (void) detectSwipeDirection {
    
    if (self.xFromCenter > ACTION_MARGIN) {
        
        [self performRightAnimation];
        
    } else if (self.xFromCenter < - ACTION_MARGIN) {
        
        [self performLeftAnimation];
        
    } else if(self.yFromCenter < - Y_ACTION_MARGIN) {
        
        [self performUpAnimation];
        
    } else if(self.yFromCenter >  Y_ACTION_MARGIN) {
        
        [self performDownAnimation];
        
    } else {
        
        [self performCenterAnimation];
        
    }
    
    // And tell the delegate
    // that the swipe just finished
    [self.delegate didEndSwipeInCard:self];
}

- (void) changeStateToIdle {
    
    // Idle state indicates that the card
    // is showing in the view, but not moving.
    self.state = kCardStateIdle;
}

- (void) changeStateToGone {
    
    // Gone state indicates that the card
    // was removed from the view
    self.state = kCardStateGone;
}

- (void) changeStateToMoving {
    
    self.state = kCardStateMoving;
    
    // Cancel Swipe if Moving but not should
    if (self.delegate && ![self.delegate shouldMoveCard:self]) {
        [self performCenterAnimation];
    }
}

#pragma mark Animation Methods

/*!
 * The view will go to the right
 */
- (void) performRightAnimation {
    
    CGPoint finishPoint = CGPointMake(500, 2 * self.yFromCenter + self.originalPoint.y);
    
    [UIView animateWithDuration:0.3  delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.center = finishPoint;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
        [self changeStateToGone];
        
        [self.delegate swipedRightInCard:self];
    }];
    
}

/*!
 * The view will got to the left
 */
- (void) performLeftAnimation {
    
    CGPoint finishPoint = CGPointMake(-500, 2 * self.yFromCenter + self.originalPoint.y);
    
    [UIView animateWithDuration:0.3  delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.center = finishPoint;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
        [self changeStateToGone];
        
        [self.delegate swipedLeftInCard:self];
    }];
    
}

/*!
 * The view will go up
 * do not remove from view
 * just perfom some goofy moves
 */
- (void) performUpAnimation {
    
    [UIView animateWithDuration:0.7
                          delay:0
         usingSpringWithDamping:0.56
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.center = self.originalPoint;
                         
                         self.transform = CGAffineTransformMakeRotation(0);
                         
                     } completion:^(BOOL finished) {
                         [self changeStateToIdle];
                         
                         [self.delegate swipedUpInCard:self];
                     }];
}

/*!
 * The view will go down
 * do not remove from view
 * just perfom some goofy moves
 */
- (void) performDownAnimation {
    
    [UIView animateWithDuration:0.7
                          delay:0
         usingSpringWithDamping:0.56
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.center = self.originalPoint;
                         
                         self.transform = CGAffineTransformMakeRotation(0);
                         
                     } completion:^(BOOL finished) {
                         [self changeStateToIdle];
                         [self.delegate swipedDownInCard:self];
                     }];
    
}

/*!
 * The view will go to the center
 * (cancel swipe) and reset the values
 */
- (void) performCenterAnimation {
    
    [UIView animateWithDuration:0.7
                          delay:0
         usingSpringWithDamping:0.56
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.center = self.originalPoint;
                         
                         self.transform = CGAffineTransformMakeRotation(0);
                         
                     } completion:^(BOOL finished) {
                         
                         [self changeStateToIdle];
                         [self.delegate didCancelSwipeInCard:self];
                     }];
}

#pragma mark - Programatically Swipe Methods

- (void) swipeLeft {
    
    // The same animation but with a delay
    CGPoint finishPoint = CGPointMake(-500, 2 * self.yFromCenter + self.originalPoint.y);
    
    [self changeStateToMoving];
    
    [UIView animateWithDuration:0.3  delay:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.center = finishPoint;
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            [self removeFromSuperview];
            [self changeStateToGone];
            [self.delegate swipedLeftInCard:self];
        }
        
    }];
}

- (void) swipeRight {
    
    // The same animation, but with a delay
    CGPoint finishPoint = CGPointMake(500, 2 * self.yFromCenter + self.originalPoint.y);
    
    [self changeStateToMoving];
    
    [UIView animateWithDuration:0.3  delay:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.center = finishPoint;
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            [self removeFromSuperview];
            [self changeStateToGone];
            [self.delegate swipedRightInCard:self];
        }
    }];
}

- (void) swipeUp {
    //TODO: Implement this
}

- (void) swipeDown {
    //TODO: Implement this
}


- (void) cancelSwipe {
    [self performCenterAnimation];
}

#pragma mark - IBActions

- (IBAction) cardButton: (id)sender {
    [self.delegate wasTouchedDownInCard:self];
}

@end