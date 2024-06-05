@tool
class_name EasingFunctions

## Standard linear interpolation, wraps built-in lerp function
static func Linear(from: Variant, to: Variant, weight: float):
    return lerp(from, to, weight)

## Eased-In interpolation
static func EaseIn(from: Variant, to: Variant, weight: float):
    return Linear(from, to, weight*weight)

## Eased-Out interpolation
static func EaseOut(from: Variant, to: Variant, weight: float):
    return Linear(from, to, 1-((1-weight)*(1-weight)))

## Eased-In-Out interpolation
static func EaseInOut(from: Variant, to: Variant, weight: float):
    return Linear(from, to, Linear(weight*weight, 1-((1-weight)*(1-weight)), weight))