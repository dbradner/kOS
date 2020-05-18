@lazyGlobal off.
clearScreen.

runOncePath("lib_utils.ks").
runOncePath("lib_manuver_guidance.ks").

function main{
    global altTarget is 100000.
    global incTarget is 0.

    print "Vehicle is in startup.".
    vehicleStartup().
    countdown().
    launchCommit().

    when alt:radar > 70000 then {
        fairingDeploy().
        print "Fairing separation.".
    }

    wait until alt:radar > 250.
    print "Begin roll program.".
    ascentGuidance().

    vehicleShutdown().
    print "MECO.".
    wait until alt:radar > 75000.

    orbitalInsertionBurn().
    print "Final orbit: " + ship:orbit:apoapsis + "m x " + ship:orbit:periapsis + "m @ " + ship:orbit:eccentricity + "deg.".

    wait 5.
    payloadDeploy().
    wait 5.
    payloadActivation().

    lock throttle to 0.
    lock steering to prograde.
    wait 10.
    unlock throttle.
    unlock steering.
}

function vehicleStartup{
    lock gravity to constant:g * (ship:body:mass/(ship:body:radius+alt:radar)^2).
    lock twrLimit to choose 3.4/(ship:availablethrust/(ship:mass * gravity)) if ship:availablethrust> 0 else 1.

    lock throttle to twrLimit.
    lock steering to heading(90,90).
}

function countdown {
    from {local countdowntTimer is 3.} until countdowntTimer = 0 step {set countdowntTimer to countdowntTimer - 1.} do {
        print "..." + countdowntTimer.
        wait 1.
    }
}

function launchCommit{
    print "Ignition.".
    until ship:availablethrust > 0 {
        safeStage().
    }
    wait 1.
    print "Launch commit.".
    until ship:verticalspeed > 0.1 {
        safeStage().
        wait 2.
    }

    when alt:radar > 80 then {
        print "Vehicle has cleared the tower.".
    }
}

function ascentGuidance{
    lock targetPitch to 89.9625 - 0.00323324 * alt:radar + 2.90845e-8 * alt:radar^2.
    local targetDirection is 90.
    lock steering to heading(targetDirection + incTarget, targetPitch).

    until apoapsis > altTarget {
        doAutostage().
    }
}

function vehicleShutdown{
    lock throttle to 0.
    lock steering to prograde.
}

function fairingDeploy{
    toggle AG10.
}

function orbitalInsertionBurn{
    planAltitudeChange(apoapsis, true).
    print "Circularizing orbit at " + ship:orbit:apoapsis + "m.".
    local mnv is nextNode.

    warpToNextBurn(30).

    executeNextManuver().
    remove mnv.
}

function payloadDeploy{
    print "Deploying payload.".
    toggle ag9.
}

function payloadActivation{
    panels on.
    print "Solar panel deployed.".
    toggle ag2.
    print "Comms active.".
}

function doAutostage{
    local elist is list().
    list engines in elist.

    for e in elist {
        if e:flameout {
            until ship:availablethrust > 0 {
                safeStage().
            }
        }
    }
}

main().