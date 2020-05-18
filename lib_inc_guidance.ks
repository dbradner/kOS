function getIncChangeDeltaV {
    parameter incchange.
    parameter nodetime.
    return 2*velocityAt(ship, nodetime):orbit:mag*sin(incchange/2).
}

function getEtaToAscDescNode {

}

function planIncChange {
    parameter endinc.
    parameter timefromnow is -1.

    if timefromnow < 0 {
        set timefromnow to eta:apoapsis.
    }

    local theta is endinc - ship:orbit:inclination.
    // local theta is ship:orbit:inclination - endinc.

    local dv is getIncChangeDeltaV(theta, time:seconds + timefromnow).

    local normaldv is dv * cos(theta/2).
    print normaldv.
    local progradedv is abs(dv * sin(theta/2)).
    print progradedv.

    local mnv is node(time:seconds + timefromnow, 0, normaldv, 0 - progradedv).
    add mnv.
}
