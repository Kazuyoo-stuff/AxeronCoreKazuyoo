#!/system/bin/sh

# // Array
VERSION="1.0 Eclips"
ANDROIDVERSION=$(getprop ro.build.version.release)
DATE="Sun 4 Aug 2024"
DEVICES=$(getprop ro.product.board)
MANUFACTURER=$(getprop ro.product.manufacturer)
API=$(getprop ro.build.version.sdk )
SETMENU="setUsingAxeron true"

# ensures the script handles cases where the variable is unset or empty.
if [ $AXERON = false ]; then
	echo "Only Support in Laxeron"
fi

# to load some configuration and declare local variables.
source $FUNCTION
source $(dirname $0)/axeron.prop
local core="ARM17:16TXsNew16zXr9a21qvWq9ei153XpNeu16HXttau1rHWstaq16PXpdew16TXsdee1qrXpder1qvXiNed17TXodeu16vXqtar16/XpNeh16jXqNar15/Xq9eu16HWqtev16Q="

# The message that appears in the terminal
echo "Installing ${name} (${version})"

# set some configuration parameters.
SETMENU
renderer="opengl"
usefl=false

# to check if there are any arguments passed to the script.
if [ -n "$1" ]; then
	if [ $1 == "-fl" ]; then
		usefl=true
		shift
	fi	
fi

# checks if the runPackage variable is empty.
if [ -z $runPackage ]; then
	echo "Package is Empty"
	exit 1
fi

# The message that appears in the terminal
echo ""
echo "▒█▀▀█ ░░ ▀▀█▀▀ ▒█░▒█ ▒█▄░▒█ ▒█▀▀▀ 
▒█░▄▄ ▀▀ ░▒█░░ ▒█░▒█ ▒█▒█▒█ ▒█▀▀▀ 
▒█▄▄█ ░░ ░▒█░░ ░▀▄▄▀ ▒█░░▀█ ▒█▄▄▄\n"
echo "     Simple Script For Gaming Mode\n"
sleep 1
echo "***************************************"
sleep 0.2
echo "• Name            : ${name}"
sleep 0.2
echo "• Version         : ${VERSION}"
sleep 0.2
echo "• Android Version : ${ANDROIDVERSION}"
sleep 0.2
echo "• Build Date      : ${DATE}"
sleep 0.2
echo "***************************************"
sleep 0.2
echo "• Devices         : ${DEVICES}"
sleep 0.2
echo "• Manufacturer    : ${MANUFACTURER}"
sleep 0.2
echo "***************************************\n"
sleep 0.2
echo "[ > ] Preparing Main Tweaks..."
sleep 2
echo "[ ! ] Detected Games [ ${runPackage} ]"
sleep 0.5
echo "[ ! ] Installing Tweaks...."
sleep 5

# activation mode / main tweaks
main_tweak () {
# activating performance mode
setprop debug.performance.tuning 1

# Surface Flinger Improvement 
setprop debug.sf.use_phase_offsets_as_durations 1
setprop debug.sf.predict_hwc_composition_strategy 0
setprop debug.sf.enable_transaction_tracing false
setprop debug.sf.enable_gl_backpressure 1
setprop debug.sf.disable_backpressure 1
setprop debug.sf.latch_unlocked 1
setprop debug.sf.hw 0
setprop debug.sf.latch_unsignaled 0
setprop debug.sf.auto_latch_unsignaled false

# Configuration FPS
setprop debug.choreographer.skipwarning 30
setprop debug.choreographer.frametime false
setprop debug.hwui.fps_divisor -1

# Configuration Hwui
setprop debug.hwui.skip_empty_damage true
setprop debug.hwui.use_buffer_age true
setprop debug.hwui.use_gpu_pixel_buffers 1
setprop debug.hwui.skia_use_perfetto_track_events false
setprop debug.hwui.app_memory_policy aggresive
setprop debug.hwui.use_main_thread true
setprop debug.hwui.disable_thread_bundle false
setprop debug.hwui.disable_functor_thread false

# other
setprop debug.kill_allocating_task 0
setprop debug.gr.numframebuffers 3
setprop debug.egl.hw 0
setprop debug.egl.profiler 0

# disables adaptive power saver.
cmd power set-adaptive-power-saver-enabled false

# enables fixed performance mode
cmd power set-fixed-performance-mode-enabled true

# Overrides memory pressure factor.
am memory-factor set "CRITICAL"

# sets and locks the thermal status of the device to STATUS.
cmd thermalservice override-status 0

# otadexopt
cmd otadexopt next "$runPackage" 
cmd otadexopt done "$runPackage"

# Performance Mode LAxeron
performance=true

# set hwui renderer
setprop debug.hwui.renderer "$renderer"

# force-stop app $1
am force-stop "$runPackage"
}
# run tweak in the background
main_tweak > /dev/null 2>&1

# The message that appears in the terminal
echo "[ - ] Tweaks succes installed.."
sleep 2
echo "[ ! ] Finalizing Installation"
echo ""

# enable jit processes.
enable_jit() {
	echo "[${1}] Enabling:"
	parameter="mode=2,downscaleFactor=0.9,fps=165:mode=3,downscaleFactor=0.5,fps=45"
	if jit speed-profile "$1" > /dev/null 2>&1; then
		echo "[ - ] Main DEX changed to speed-profile"
	fi
	if jit speed-profile --sdex "$1" > /dev/null 2>&1; then
		echo "[ - ] Secondary DEX to speed-profile"
	fi
	if settings put global g_tune "$1" > /dev/null 2>&1; then
		echo "[ - ] all done."
		echo ""
		sleep 2
		echo "Open the LAxeron menu, please wait.."
	fi
}

# disable jit processes.
disable_jit() {
	echo "[${1}] Disabling:"
	if jit -r "$1" > /dev/null 2>&1; then
		echo "[ - ] Main DEX changed to default"
	fi
	if jit -r --sdex "$1" > /dev/null 2>&1; then
		echo "[ - ] Secondary DEX changed to default"
	fi
}

# check several conditions and set device properties and enable some configurations.
if [ $(getprop dalvik.vm.usejit) ]; then
	local gtune=$(settings get global g_tune)
	if [ -n "$runPackage" ] && [ -n "$gimpact" ] && [ "$gimpact" != "$runPackage" ]; then
		dumpsys deviceidle whitelist -$gtune
		dumpsys deviceidle whitelist +$runPackage
		disable_jit "$gtune"
		enable_jit "$runPackage"
	elif [ "$gimpact" != "$runPackage" ]; then
		dumpsys deviceidle whitelist +$runPackage
		enable_jit "$runPackage"
	else
		echo "[${runPackage:-" - "}] ${name} installed"
	fi
fi

# check the value of the usefl variable and execute the command
if [ $usefl = true ]; then
	flaunch $runPackage
else
	storm -x $core
fi
      
	     # bye bye......
       # thanks all contributors...
