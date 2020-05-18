@lazyGlobal off.
clearScreen.

runOncePath("lib_utils.ks").
runOncePath("lib_manuver_guidance.ks").

function intercept {
    local offset is 0.

    local timeToNewAlt is timeToNewOrbit(averageAlt(ship:orbit)+ship:body:radius, averageAlt(target:orbit)+ship:body:radius).
    print timeToNewAlt.
    local targetMotion is calculateTargetMotion(timeToNewAlt).
    print targetMotion.
    local reqMnvAngle is calculateManuverAngle(offset, targetMotion).
    print reqMnvAngle.
    local mnvDelta is calculateMotionDelta().
    print mnvDelta.
    local currentMnvAngle is calculateTargetOffset().
    print currentMnvAngle.

    local degToTravel is mod(currentMnvAngle + (360-reqMnvAngle), 360).
    print degToTravel.
    local mnvTime is (degToTravel / mnvDelta).
    print (degToTravel / mnvDelta).

    planAltitudeChange(averageAlt(target:orbit), false, 999999, mnvTime).
}

function averageAlt {
    parameter orb.
    return (orb:periapsis + orb:apoapsis) / 2.
}