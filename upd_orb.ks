@lazyGlobal off.
clearScreen.

runOncePath("lib_utils.ks").
runOncePath("lib_manuver_guidance.ks").

planAltitudeChange(1250000, true).

executeNextManuver().
remove nextNode.

planAltitudeChange(periapsis, false).

executeNextManuver().
remove nextNode.

runPath("slot_into_orbit.ks").

executeNextManuver().
wait 1.
remove nextNode.
wait 1.
executeNextManuver().
wait 1.
remove nextNode.
wait 1.