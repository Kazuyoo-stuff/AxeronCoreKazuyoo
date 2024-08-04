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

echo "welcome"
echo "kontol memek peler bangsat"

enable_jit() {
	echo "[${1}] Enabling:"
	parameter="mode=2,downscaleFactor=0.9,fps=165:mode=3,downscaleFactor=0.5,fps=45"
	if jit speed-profile "$1" > /dev/null 2>&1; then
		echo "[ - ] Main DEX changed to speed-profile"
	fi
	if jit speed-profile --sdex "$1" > /dev/null 2>&1; then
		echo "[ - ] Secondary DEX to speed-profile"
	fi
	if settings put global g_impact "$1" > /dev/null 2>&1; then
		echo "[${1}] ${name} installed"
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
	local gimpact=$(settings get global g_impact)
	if [ -n "$runPackage" ] && [ -n "$gimpact" ] && [ "$gimpact" != "$runPackage" ]; then
		dumpsys deviceidle whitelist -$gimpact
		dumpsys deviceidle whitelist +$runPackage
		disable_jit "$gimpact"
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
