#!/system/bin/sh

if [ $AXERON = false ]; then
	echo "Only Support in Laxeron"
fi

source $FUNCTION
source $(dirname $0)/axeron.prop

echo "Removing ${name} (${version})"
{
cmd power set-adaptive-power-saver-enabled false
cmd power set-fixed-performance-mode-enabled false
am memory-factor set "NORMAL"
cmd thermalservice reset
} > /dev/null 2>&1
am force-stop "$runPackage"

disable_jit() {
	echo "[${1}] Disabling:"
	if jit -r "$1" > /dev/null 2>&1; then
		echo "[ - ] Main DEX changed to default"
	fi
	if jit -r --sdex "$1" > /dev/null 2>&1; then
		echo "[ - ] Secondary DEX changed to default"
	fi
	if settings delete global g_impact > /dev/null 2>&1; then
        echo "[ - ] all tweak cmd changed to default"
		echo "[${1}] ${name} removed"
	fi
}

if [ $(getprop dalvik.vm.usejit) ]; then
	local gimpact=$(settings get global g_impact)
	if [ -n "$runPackage" ] && [ -n "$gimpact" ] && [ "$gimpact" != "$runPackage" ]; then
		disable_jit "$gimpact"
		disable_jit "$runPackage"
	elif [ "$gimpact" == "$runPackage" ]; then
		disable_jit "$runPackage"
	else
		echo "[${runPackage:-" - "}] ${name} removed"
	fi
fi
