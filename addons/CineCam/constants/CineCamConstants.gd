class_name CineCamConstants

## The follow modes of a [VirtualCamera].
## Value represents what properties to display
## in the inspector:
enum FollowModes {
    STATIC = 0,
    PERSPECTIVE = 1,
    FOLLOW = 559,
    ORBIT = 7,
    PATH_FOLLOW = 470,
}

## The aim modes of a [VirtualCamera].
## Value represents what properties to display
## in the inspector:
enum AimModes {
    STATIC = 0,
    PERSPECTIVE = 1,
    LOCK_ON = 3,
}

## The transition modes of a [Transition].
enum TransitionModes {
    CUT = 0,
    EASED = 1,
}

## The easing modes of a [member Transition.easing_function].
## Only used if a transition has the mode = TransitionModes.EASED
enum EasingModes {
    LINEAR = 0,
    EASE_IN = 1,
    EASE_OUT = 2,
    EASE_IN_OUT = 3,
}

## Flags for the follow properties of a [VirtualCamera]
enum FollowProperties {
    TARGET = 1,
    LOCK = 2,
    SPEED = 4,
    TARGET_OFFSET = 8,
    TRACKING_PATH = 16,
    IS_DAMPENED = 32,
    MOVE_ALONG = 64,
    LOOP = 128,
    PATH_OFFSET = 256,
    ROTATE_WITH_TARGET = 512,
}

## Flags for the aim properties of a [VirtualCamera]
enum AimProperties {
    TARGET = 1,
    LOCK = 2,
}

## Flags for properties a [Transition] interpolates over
enum TransitionProperties {
    POSITION = 1,
    ROTATION = 2,
    FOV = 4,
}