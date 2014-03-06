#!/bin/bash

# quick switch between different folders in android project.


# declare supported project list here
# ==================================
declare -A PROJECT_LIST
PROJECT_LIST['kitkat']='kk'
PROJECT_LIST['jb_3.2']='jb_3.2'
PROJECT_LIST['jb_3.2.1']='jb_3.2.1'
PROJECT_LIST['kk_3.5']='kk_3.5'
PROJECT_LIST['jb_3.2.1_rb1']='jb_3.2.1_rb1'
PROJECT_LIST['jb_3.2.1_rb4']='jb_3.2.1_rb4'
PROJECT_LIST['jb_3.2.1.4']='jb_3.2.1.4'
# ==================================

# declare sub modules list and it's abbreviation(s).
# ==================================
declare -A SUB_MODULE_LIST
SUB_MODULE_LIST['camera_apk']='packages/apps/Camera'
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
MOD_ABBR_DICT['camera_apk']='app apk'
MOD_ABBR_DICT['gallery_apk']='pic'
MOD_ABBR_DICT['camera_hal']='hal qcamera'
MOD_ABBR_DICT['mm_camera']='mm'
MOD_ABBR_DICT['mm_core']='core'
MOD_ABBR_DICT['msm_camera_drivers']='msm'
MOD_ABBR_DICT['dts']='dts'
MOD_ABBR_DICT['frameworks']='framework fw'
MOD_ABBR_DICT['frameworks_base']='base'
MOD_ABBR_DICT['frameworks_av']='av'
MOD_ABBR_DICT['output']='out'
# ==================================


#full path = ${PROJECT_ROOT_DIR}/${PROJECT_NAME}/${SRC_CODE_PATH}/
#PROJECT_ROOT_DIR=~/project
PROJECT_ROOT_DIR=/local/mnt/workspace/project
#PROJECT_ROOT_DIR=/local/mnt/workspace/gaochen
SRC_CODE_PATH=src
PROJECT_NAME=""


TARGET_NAME="msm8974"

CANNOT_FIND_MODULE_DIR="cannot_find_module_dir"


echo "======================================="
echo "acd()"
echo "  -- quick switch between diff folders"
echo "     in android project"
echo ""
echo "======================================="

parse_input_params()
{
	echo "[INF] parsing input params << $@ >>"

	module_dir=""
	if [[ "$#" -eq 0 ]]; then
		echo "[DBG] no input params, we need change to the top dir of current project ...(as the behavior of 'cd')"
		return
	elif [[ "$#" -gt 2 ]]; then
		echo "[WRN] too much params... only using the first param: '$1'"
	fi

	lookup_module_dir $1

	echo "[DBG] after parse params($1). module_dir: $module_dir"

}

lookup_module_dir()
{
	echo "[DBG] lookup_module_dir() E. parsing params: $1"
	
	for _key in ${!MOD_ABBR_DICT[@]} ; do
		echo "[DBG] $_key -> ${MOD_ABBR_DICT[$_key]}"
		if echo "${MOD_ABBR_DICT[$_key]}" | grep -q -E -i "\<$1\>" ; then
			module_dir="${SUB_MODULE_LIST[$_key]}"
			echo "[DBG] found! module_dir: $module_dir"
			break;
		fi
	done
}


lookup_module_dir_legacy()
{
	echo "[DBG] lookup_module_dir() E. parsing params: $1"

	case "$1" in
		"app" | "apk" | "APP" | "APK" )
			module_dir="$CAMERA_APP_DIR"
			;;

		"HAL" | "hal" | "Hal" )
			module_dir="$CAMERA_HAL_DIR"
			;;

		"mm" | "MM" | "mm-camera" )
			module_dir="$CAMERA_VENDOR_DIR"
			;;

		"core" | "mm-camera-core" )
			module_dir="$CAMERA_MM_CORE_DIR"
			;;

		"fw" | "FW" | "frameworks" )
			module_dir="frameworks"
			;;

		"base" | "BASE" )
			module_dir="frameworks/base"
			;;
		"av" | "AV" )
			module_dir="frameworks/av"
			;;
		"kernel" | "driver" | "k" )
			module_dir="kernel/drivers"
			;;
		"out" )
			module_dir="$__OUTPUT_DIR"
			;;
		"msm" )
			module_dir="$CAMERA_DRIVER_DIR"
			;;
		"dts" )
			module_dir="$__DTS"
			;;
		* )
			echo "unknown param($1), set module_dir to $CANNOT_FIND_MODULE_DIR"
			module_dir="$CANNOT_FIND_MODULE_DIR"
	esac
}


#
# we just use this function to confirm that we're really under a project folder.
# actually we don't need this for switching between different folders.
#
guess_project_name_from_cwd()
{
	echo "guess_project_name_from_cwd() E. cwd: $(pwd)"
	project_name=""

	for project_entry in ${PROJECT_LIST[@]} ; do
		echo "matching project_entry: $project_entry"
		if pwd | grep -q "${PROJECT_ROOT_DIR}/${project_entry}/" ; then
			project_name="$project_entry"
			echo "[DBG] matched! project name: $project_name"
			break
		fi
	done

}

guess_project_name_from_cwd_legacy()
{
	echo "guess_project_name_from_cwd() E. cwd: $(pwd)"
	project_name=""

	if pwd | grep -q "${PROJECT_ROOT_DIR}/${PJ_JB_8x25Q}\b"; then
		project_name="$PJ_JB_8x25Q"
		echo "[DBG] in poject: PJ_JB_8x25Q, project name: $project_name"
	elif pwd | grep -q "${PROJECT_ROOT_DIR}/${PJ_ICS_8x25}\b"; then
		project_name="$PJ_ICS_8x25"
		echo "[DBG] in poject: PJ_ICS_8x25, project name: $project_name"
	elif pwd | grep -q "${PROJECT_ROOT_DIR}/${PJ_JB_MR1}\b"; then
		project_name="$PJ_JB_MR1"
		echo "[DBG] in project: PJ_JB_MR1, project name: $project_name"
	else
		echo "[ERR] current not in any project!!!!"
		#exit 1
		return
	fi
}

switch_to_dest_dir()
{

	guess_project_name_from_cwd
	if [[ -z "project_name" ]]; then
		echo "[DGB] no in any project, using 'cd' directly..."
		cd $@
		return
	fi

	echo "[DBG] input params($#): $@"
	parse_input_params $@

	dest_dir=""
	if [[ -z "$module_dir" ]]; then
		echo "[DBG] no module specified.  switch to the top dir of current project."
	else
		echo "[DBG] module_dir: $module_dir"
	fi
	dest_dir="${PROJECT_ROOT_DIR}/${project_name}/${SRC_CODE_PATH}/${module_dir}"
	
	echo "[INF] dest_dir: $dest_dir"

	if [[ -d "$dest_dir" ]]; then
		echo "[DBG] change to dir: $dest_dir"
		cd $dest_dir
	else
		echo "[ERR] invalid dest dir: $dest_dir !!! just keep in current dir."
	fi

	unset project_name
	unset module_dir
}

acd () 
{
	switch_to_dest_dir $@
} > /dev/null



