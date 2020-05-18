@lazyGlobal off.
clearScreen.

runOncePath("lib_utils.ks").
runOncePath("lib_manuver_guidance.ks").

function circularize {
    local newalt is 130000.

    planAltitudeChange(newalt, false).
    
    warpToNextBurn(15).

    local mnv is nextNode.
    executeNextManuver().
    wait 1.
    remove mnv.

    planAltitudeChange(ship:orbit:apoapsis, true).

    warpToNextBurn().

    set mnv to nextNode.
    executeNextManuver().
    wait 1.
    remove mnv.
}

circularize().