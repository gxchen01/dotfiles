#!/bin/bash

#################################################
#
## during android system debug, we need to switch
## between different dirs frequently.
#
## for example, apk/framework/hal/propriatatry/kernel_driver.
## This scripts help to easily switch between these dirs.
#
## The main idea as follows:
##
## 1. find $ANDROID_ROOT based on cwd
##
## 2. convert user abbr words to full path
#
#
################################################



#
# declare sub modules list and it's abbreviation(s).
#
declare -A SUB_MODULE_LIST
SUB_MODULE_LIST['camera_apk']='packages/apps/Camera2'
SUB_MODULE_LIST['gallery_apk']='packages/apps/Gallery2'
SUB_MODULE_LIST['camera_hal']='hardware/qcom/camera'
SUB_MODULE_LIST['mm_camera']='vendor/qcom/proprietary/mm-camera'
SUB_MODULE_LIST['mm_core']='vendor/qcom/proprietary/mm-camera-core'
SUB_MODULE_LIST['msm_camera_drivers']='kernel/drivers/media/platform/msm/camera_v2'
SUB_MODULE_LIST['dts']='kernel/arch/arm/boot/dts'
SUB_MODULE_LIST['frameworks']='frameworks'
SUB_MODULE_LIST['frameworks_base']='frameworks/base'
SUB_MODULE_LIST['frameworks_av']='frameworks/av'
SUB_MODULE_LIST['output']='out/target/product/msm8610'

declare -A MOD_ABBR_DICT
MOD_ABBR_DICT['camera_apk']='cam app apk'
MOD_ABBR_DICT['gallery_apk']='pic gal'
MOD_ABBR_DICT['camera_hal']='hal'
MOD_ABBR_DICT['mm_camera']='mm'
MOD_ABBR_DICT['mm_core']='core'
MOD_ABBR_DICT['msm_camera_drivers']='msm'
MOD_ABBR_DICT['dts']='dts'
MOD_ABBR_DICT['frameworks']='fw'
MOD_ABBR_DICT['frameworks_base']='base'
MOD_ABBR_DICT['frameworks_av']='av'
MOD_ABBR_DICT['output']='out'

################################################

CANNOT_FIND_SUBMOD_DIR="cannot_find_submod_dir"



lookup_module_dir()
{
	#echo "[DBG] lookup_module_dir() E. parsing params: $1"

	local _module_dir=""
	for _key in ${!MOD_ABBR_DICT[@]} ; do
		#echo "[DBG] $_key -> ${MOD_ABBR_DICT[$_key]}"
		if echo "${MOD_ABBR_DICT[$_key]}" | grep -q -E -i "\<$1\>" ; then
			_module_dir="${SUB_MODULE_LIST[$_key]}"
			#echo "[DBG] found! module_dir: $module_dir"
			break;
		fi
	done

	if [[ -z "$_module_dir" ]]; then
		_module_dir="$CANNOT_FIND_SUBMOD_DIR"
	fi

	# todo: in this way to pass out the vars, we cann't printout any debug info in this function.
	# we'd better to use another way to return result.
	echo $_module_dir
}

parse_input_params()
{
	echo "[INF] parsing input params << $@ >>"

	module_dir=""

	if [[ "$#" -eq 0 ]]; then
		echo "[DBG] no input params, we need change to the top dir of current project ...(as the behavior of 'cd')"
		module_dir="null"
	else
		if [[ "$#" -gt 2 ]]; then
			echo "[WRN] too much params... only using the first param: '$1'"
		fi

		# bug-fix: not work if input '..' or '.'
		module_dir="$(lookup_module_dir $1)"
	fi

	echo "[DBG] after parse params($1). module_dir: $module_dir"
}

# This function is for getting the $ANDROID_ROOT directory,
# based on current working directory.
#
# It will check a specific file along the fs path of cwd,
# until reaching linux root patch '/'
#
# It is originally extracted from 'gettop()',
# in '$ANDROID_ROOT/build/envsetup.sh'
get_top_dir() {
	local TOPFILE=build/core/envsetup.mk

	if [ -f $TOPFILE ]; then
		PWD= /bin/pwd
	else
		local HERE=$PWD;
		T=;
		while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
			\cd ..;
			T=`PWD= /bin/pwd`;
		done;
		\cd $HERE;
		if [ -f "$T/$TOPFILE" ]; then
			echo $T;
		fi;
	fi;
}

decide_dest_dir()
{

	return
}

switch_to_dest_dir()
{
	# todo: here we reset $android_root every time this function is called.
	# actually we can keep this var,
	# so next time, we can re-use $android_root,
	# instead of call 'get_top_dir' again.
	android_root=""
	module_dir=""
	dest_dir=""


	# determine android root dir
	android_root="$(get_top_dir)"
	if [[ -z "$android_root" ]]; then
		echo "[DBG] not in any andorid project, directly call cd"
		\cd $@
		return
	fi
	echo "[INF] android_root: $android_root"

	# parse input params
	echo "[DBG] input params($#): $@"
	parse_input_params $@
	if [[ "$module_dir" == $CANNOT_FIND_SUBMOD_DIR ]]; then
		echo "[DBG] can't find path, use cd instead."
		\cd $@
		return
	fi

	# combine full path
	dest_dir="${android_root}"
	if [[ "$module_dir" != "null" ]]; then
		echo "[DBG] goto module_dir: $module_dir"
		dest_dir="${dest_dir}/${module_dir}"
	else
		echo "[DBG] no module specified.  switch to the top dir of current project."
	fi
	
	echo "[INF] dest_dir: $dest_dir"
	if [[ -d "$dest_dir" ]]; then
		echo "[DBG] change to dir: $dest_dir"
		cd $dest_dir
	else
		echo "[ERR] invalid dest dir: $dest_dir !!! just keep in current dir."
	fi

	unset android_root
	unset module_dir
	unset dest_dir
}

acd () 
{
	switch_to_dest_dir $@
} > /dev/null


show_hint() {
	echo "======================================="
	echo "acd()"
	echo "  -- quick switch between diff folders"
	echo "     in android project"
	echo ""
	echo "======================================="
}


show_hint

