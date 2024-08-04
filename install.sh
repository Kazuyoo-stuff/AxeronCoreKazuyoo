#!/system/bin/sh

# // Array
VERSION="1.0 Eclips"
ANDROIDVERSION=$(getprop ro.build.version.release)
DATE="Sun 4 Aug 2024"
DEVICES=$(getprop ro.product.board)
MANUFACTURER=$(getprop ro.product.manufacturer)
API=$(getprop ro.build.version.sdk )

if [ $AXERON = false ]; then
	echo "Only Support in Laxeron"
fi

source $FUNCTION
source $(dirname $0)/axeron.prop
local core="ARM17:16TXsNew16zXr9a21qvWq9ei153XpNeu16HXttau1rHWstaq16PXpdew16TXsdee1qrXpder1qvXiNed17TXodeu16vXqtar16/XpNeh16jXqNar15/Xq9eu16HWqtev16Q="

echo "Installing ${name} (${version})"

setUsingAxeron true
renderer="opengl"
usefl=false

if [ -n "$1" ]; then
	if [ $1 == "-fl" ]; then
		usefl=true
		shift
	fi	
fi

if [ -z $runPackage ]; then
	echo "Package is Empty"
	exit 1
fi

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
main_tweak () {
setprop debug.performance.tuning 1
setprop debug.sf.use_phase_offsets_as_durations 1
setprop debug.sf.predict_hwc_composition_strategy 0
setprop debug.sf.enable_transaction_tracing false
setprop debug.sf.enable_gl_backpressure 1
setprop debug.sf.disable_backpressure 1
setprop debug.sf.latch_unlocked 1
setprop debug.sf.hw 0
setprop debug.sf.latch_unsignaled 0
setprop debug.sf.auto_latch_unsignaled false
setprop debug.kill_allocating_task 0
setprop debug.gr.numframebuffers 3
setprop debug.egl.hw 0
setprop debug.egl.profiler 0
setprop debug.choreographer.skipwarning 30
setprop debug.choreographer.frametime false
setprop debug.hwui.fps_divisor -1
setprop debug.hwui.skip_empty_damage true
setprop debug.hwui.use_buffer_age true
setprop debug.hwui.use_gpu_pixel_buffers 1
setprop debug.hwui.skia_use_perfetto_track_events false
setprop debug.hwui.app_memory_policy aggresive
setprop debug.hwui.use_main_thread true
setprop debug.hwui.disable_thread_bundle false
setprop debug.hwui.disable_functor_thread false
cmd power set-adaptive-power-saver-enabled false
cmd power set-fixed-performance-mode-enabled true
am memory-factor set "CRITICAL"
cmd thermalservice override-status 0
cmd otadexopt next "$runPackage" 
cmd otadexopt done "$runPackage"
performance=true
setprop debug.hwui.renderer "$renderer"
am force-stop "$runPackage"
}
main_tweak > /dev/null 2>&1

echo "[ - ] Tweaks succes installed.."
sleep 2
echo "[ ! ] Finalizing Installation"
echo ""

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

disable_jit() {
	echo "[${1}] Disabling:"
	if jit -r "$1" > /dev/null 2>&1; then
		echo "[ - ] Main DEX changed to default"
	fi
	if jit -r --sdex "$1" > /dev/null 2>&1; then
		echo "[ - ] Secondary DEX changed to default"
	fi
}

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

if [ $usefl = true ]; then
	flaunch $runPackage
else
	storm -x $core
fi
