@lazyGlobal off.
clearScreen.

runOncePath("lib_utils.ks").
runOncePath("lib_manuver_guidance.ks").

function slot_into_orbit {
    local timeToNewAlt is timeToNewOrbit(averageAlt(ship:orbit)+ship:body:radius, averageAlt(target:orbit)+ship:body:radius).
    print timeToNewAlt.
    local targetMotion is calculateTargetMotion(timeToNewAlt).
    print targetMotion.
    local reqMnvAngle is calculateManuverAngle(90, targetMotion).
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
    local mnv is nextNode.
    local timeToApAfterMnv is mnv:eta +  (orbitAt(ship,time+mnv:eta + 1):period/2).
    planAltitudeChange(mnv:orbit:apoapsis, true, 999999, timeToApAfterMnv).
    executeNextManuver().
    wait 1.
    remove nextNode.
    wait 1.
    executeNextManuver().
    wait 1.
    remove nextNode.
    wait 1.
}

function averageAlt {
    parameter orb.
    return (orb:periapsis + orb:apoapsis) / 2.
}

// Need to first figure out how long the transfer is going to take. Then calculate the angle of manuver. Then, calculate the current angle, the difference between current and ideal, divide that by the delta to get time of manuver.

slot_into_orbit().