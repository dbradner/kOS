function safeStage {
    wait until stage:ready.
    stage.
}

function warpToNextBurn{
    parameter frontPorch is 45.

    lock maxAcceleration to ship:maxthrust/ship:mass.
    local mnv is nextNode.
    local burnDuration is mnv:deltav:mag/maxAcceleration.

    warpto(time:seconds + mnv:eta - (burnDuration/2 + frontPorch)).
}