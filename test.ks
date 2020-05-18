@lazyGlobal off.
clearScreen.

runOncePath("lib_utils.ks").
runOncePath("lib_manuver_guidance.ks").
runOncePath("lib_inc_guidance.ks").

function test {
    planIncChange(90).

    warpToNextBurn(15).

    local mnv to nextNode.
    executeNextManuver().
    wait 1.
    remove mnv.
}

test().