@lazyGlobal off.
clearScreen.

function main{
    vehicleStartup().
    countdown().
    launchCommit().
    ascentGuidance().
    vehicleShutdown().
    fairingDeploy().
    wait until alt:radar > 75000.
    orbitalInsertionBurn().
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
    toggle ag1.
    print "Vehicle is in startup.".

    lock throttle to 1.
    lock steering to heading(90, 90).
}

function countdown {
    from {local countdowntTimer is 3.} until countdowntTimer = 0 step {set countdowntTimer to countdowntTimer - 1.} do {
        print "..." + countdowntTimer.
        wait 1.
    }
}

function launchCommit{
    print "Launch commit.".
    safeStage().
    safeStage().

    wait until alt:radar > 100.

    print "Vehicle has cleared the tower.".

    wait until alt:radar > 250.
}

function ascentGuidance{
    print "Begin roll program.".
    lock targetPitch to 89.9625 - 0.00323324 * alt:radar + 2.90845e-8 * alt:radar^2.
    local targetDirection is 90.
    lock steering to heading(targetDirection, targetPitch).

    until apoapsis > 100000 {
        doAutostage().
    }
}

function vehicleShutdown{
    print "SECO 1.".
    lock throttle to 0.
    lock steering to prograde.
}

function fairingDeploy{
    wait until alt:radar > 70000.
    toggle AG10.
    print "Fairing separation.".
}

function orbitalInsertionBurn{
    local apoapsisTime is time + eta:apoapsis.
    local apoapsisVelocity is velocityAt(ship, apoapsisTime):orbit:mag.

    local bodyDistance is kerbin:radius+ship:obt:apoapsis.

    local orbitalVelocity is sqrt(constant:g * kerbin:mass * ((2/bodyDistance)-(1/bodyDistance))).

    local dV is orbitalVelocity - apoapsisVelocity.
    local mnv is node(apoapsisTime:seconds, 0, 0, dV).
    add mnv.
    print "Circularizing orbit at " + ship:orbit:apoapsis + "m.".
    executeNextManuver().
    print "SECO 2.".
    print "Final orbit: " + ship:orbit:apoapsis + "m x " + ship:orbit:periapsis + "m @ " + ship:orbit:eccentricity + "deg.".
    remove mnv.
}

function payloadDeploy{
    print "Deploying payload.".
    until stage:number = 0{
        safeStage().
    }
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
            print "MECO.".
            until ship:availablethrust > 0 {
                safeStage().
            }
            print "Second stage ignition.".
        }
    }
}

function safeStage {
    wait until stage:ready.
    stage.
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

    lock steering to prograde.
    lock throttle to 0.
    unlock steering.
    unlock throttle.
}

main().