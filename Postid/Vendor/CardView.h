#import <UIKit/UIKit.h>


@protocol CardDelegate;

typedef NS_ENUM(NSUInteger, kCardState) {
    kCardStateIdle = 0,
    kCardStateMoving = 1,
    kCardStateGone = 2
};

// The Position of the Card
typedef NS_ENUM(NSInteger, kCardPosition) {
    kCardPositionTop = 0,
    kCardPositionBack = 1
};

/*!
 *    Implements the Views inside the Cards
 */
@interface CardView : UIView

#pragma mark - Properties

/*!
 *    Defines the current state of the card
 */
@property (nonatomic) kCardState state;

/*!
 *    The Weight of the Card indicates its position in the stack
 */
@property (nonatomic) kCardPosition position;

/*!
 * The delegate that will listen to the notifications
 * on created on pan gesture recognizers
 */
@property (nonatomic, weak) id <CardDelegate> delegate;

/*!
 *    Where in the array is located the  view
 */
@property (nonatomic) NSInteger index;

#pragma mark - Methods

#pragma mark Init

/*!
 * Designated Initializer
 *
 * This method inits the view
 * and set the  to fetch
 * also renders the view with 's data
 *
 * @param CGRect frame for view's bounds
 * @param ViewDelegate delegate to send events
 * @param  *  to render the view info
 */
- (void) setFrame:(CGRect)frame delegate:(id<CardDelegate>) delegate;

#pragma mark Instance

/*!
 * Swipes the view to the left
 * programatically
 */
- (void) swipeLeft;

/*!
 * Swipes the view to the right
 * programatically
 */
- (void) swipeRight;

/*!
 * Swipes the view up
 * programatically
 */
- (void) swipeUp;

/*!
 * Swipes the view down
 * programatically
 */
- (void) swipeDown;

/*!
 *    Cancels a Swipe
 */
- (void) cancelSwipe;

@end


@protocol CardDelegate <NSObject>

#pragma mark - Delegate Methods

/*!
 * Method called when the view will begin pan gesture
 * @param Card * Card
 */
- (void) willBeginSwipeInCard : (CardView *) card;

/*!
 * Method called when the view did end pan gesture
 * @param Card * Card
 */
- (void) didEndSwipeInCard : (CardView *) card;

/*!
 * Method called when the view did not reach a detected position
 * @param Card * Card
 */
- (void) didCancelSwipeInCard : (CardView *) card;

/*!
 * Method called when the view was swiped left
 * @param Card * Card
 */
- (void) swipedLeftInCard : (CardView *) card;

/*!
 * Method called when the view was swiped right
 * @param Card * Card
 */
- (void) swipedRightInCard : (CardView *) card;

/*!
 * Method called when the view was swiped up
 * @param Card * Card
 */
- (void) swipedUpInCard : (CardView *) card;

/*!
 * Method called when the view was swiped down
 * @param Card * Card
 */
- (void) swipedDownInCard : (CardView *) card;

/*!
 * Method called when the view button was pressed
 * @param Card * Card;
 */
- (void) wasTouchedDownInCard : (CardView *) card;

/*!
 *    Method called when the state was changed
 *
 *    @param  Card * Card;
 */
- (void) didChangeStateInCard: (CardView *) card;

/*!
 *    Ask the delegate if the card should move
 *
 *    @param Card the card
 *
 *    @return YES if the card should move
 */
- (BOOL) shouldMoveCard: (CardView *) card;

@end