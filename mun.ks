@lazyGlobal off.
clearScreen.

runOncePath("lib_utils.ks").
runOncePath("lib_manuver_guidance.ks").
runOncePath("lib_intercept.ks").
runOncePath("lib_inc_guidance.ks").

function gotomun {
    set target to body("minmus").

    intercept().

    planIncChange(-14, orbitAt(ship, time:seconds + nextNode:eta):period * 0.25).

    warpToNextBurn(15).

    local mnv is nextNode.
    executeNextManuver().
    wait 1.
    remove mnv.

    warpToNextBurn(15).

    set mnv to nextNode.
    executeNextManuver().
    wait 1.
    remove mnv.

    warpto(time:seconds + ship:orbit:nextpatcheta - 5).

    wait ship:orbit:nextpatcheta + 10.

    if ship:periapsis < 0 {
        set mnv to node(time:seconds + 30, 0, 50, 0).
        add mnv.
        executeNextManuver().
        remove mnv.
    }

    planAltitudeChange(130000, false, 999999, 20).

    set mnv to nextNode.
    executeNextManuver().
    wait 1.
    remove mnv.

    planAltitudeChange(ship:orbit:periapsis, false).

    warpToNextBurn(15).

    set mnv to nextNode.
    executeNextManuver().
    wait 1.
    remove mnv.
}

gotomun().