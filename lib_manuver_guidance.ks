function timeToNewOrbit {
    parameter startObt is ship:periapsis.
    parameter endObt is ship:apoapsis.
    return constant:pi * sqrt((startObt + endObt)^3/(8*ship:body:mu)).
}

function calculateTargetMotion {
    parameter timeOfMotion.
    local degPerSec is 360/target:orbit:period.
    return degPerSec * timeOfMotion.
}

function calculateTargetOffset {
    return mod((180 + target:geoPosition:lng) - (180 + ship:geoposition:lng)+360, 360).
}

function calculateMotionDelta {
    return 360/ship:orbit:period - 360/target:orbit:period.
}

function calculateManuverAngle {
    parameter offset.
    parameter targetMotion.
    local angle is 180 - (targetMotion + offset).
    return choose angle if angle > 0 else 360 + angle.
}

function executeNextManuver {
    local mnv is nextNode.
    print "Node in " + round(mnv:eta) + ".".

    lock maxAcceleration to ship:maxthrust/ship:mass.
    local burnDuration is mnv:deltav:mag/maxAcceleration.

    print "Estimated burn duration " + burnDuration + ".".

    wait until mnv:eta < (burnDuration/2 + 45).
    lock steering to mnv:deltav.
    wait until mnv:eta < (burnDuration/2).

    local dV0 is mnv:deltav.
    lock throttle to min(mnv:deltav:mag/maxAcceleration, 1).

    until false { 
        if mnv:deltav:mag < 0.1 or vDot(dV0, mnv:deltav) < 0 {
            print "Finalizing burn, remaining dV " + round(mnv:deltav:mag,1) + "m/s, vdot: " + round(vdot(dV0, mnv:deltav),1).

            wait until vdot(dv0, mnv:deltav) < 0.5.

            lock throttle to 0.
            print "End burn, remain dv " + round(mnv:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, mnv:deltav),1).
            break.
        }
    }

    lock throttle to 0.
    unlock steering.
    unlock throttle.
}

function planAltitudeChange{
    parameter newAlt.
    parameter atApo.
    parameter maxdV is 999999.
    parameter mnvTimeSet is 0.

    if atApo = false and ship:periapsis < ship:body:atm:height {
        print "Ship is suborbital, cannot raise apoapsis.".
        return.
    }

    local mnvTime is time.
    if mnvTimeSet > 0 {
        set mnvTime to mnvTime + mnvTimeSet.
    } else {
        set mnvTime to choose time + eta:apoapsis if atApo else time + eta:periapsis.
    }
    local mnvStartingVel is velocityAt(ship, mnvTime):orbit:mag.

    local bodyDistance is ship:body:altitudeof(positionAt(ship,mnvTime)) + ship:body:radius.
    local semiMajAxis is ((newAlt + ship:body:radius) + bodyDistance) / 2.

    local mnvEndingVel is sqrt(ship:body:mu * ((2/bodyDistance) - (1/semiMajAxis))).

    local dv is mnvEndingVel - mnvStartingVel.
    local mnv is node(mnvTime:seconds, 0, 0, dv).
    if dv > maxdV {
        set mnv to node(mnvTime:seconds, 0, 0, maxdV).
    }
    add mnv.
}

// Need to first figure out how long the transfer is going to take. Then calculate the angle of manuver. Then, calculate the current angle, the difference between current and ideal, divide that by the delta to get time of manuver.