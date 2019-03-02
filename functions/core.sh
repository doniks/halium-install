#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs_to_img() {
	image_size=$1

	qemu-img create -f raw $IMAGE_DIR/rootfs.img $image_size
	sudo mkfs.ext4 -O ^metadata_csum -O ^64bit -F $IMAGE_DIR/rootfs.img
	sudo mount $IMAGE_DIR/rootfs.img $ROOTFS_DIR
	sudo tar -xf $ROOTFS_TAR -C $ROOTFS_DIR
}

function convert_rootfs_to_dir() {
	sudo tar -xf $ROOTFS_TAR -C $ROOTFS_DIR
}

function convert_androidimage() {
	if file $AND_IMAGE | grep "ext[2-4] filesystem"; then
		cp $AND_IMAGE $IMAGE_DIR/system.img
	else
		simg2img $AND_IMAGE $IMAGE_DIR/system.img
	fi
}

function shrink_android_img() {
	# FIXME: does it make sense to shrink if you don't have to so simg2img? if so, this code should move over there so we only execute if needed
	e2fsck -fy $IMAGE_DIR/system.img
	resize2fs -p -M $IMAGE_DIR/system.img
}

function inject_androidimage() {
	sudo mv $IMAGE_DIR/system.img $ROOTFS_DIR
}

function unmount_rootfs() {
	sudo umount $ROOTFS_DIR
}

function flash_rootfs_img() {
	if ! adb push $IMAGE_DIR/rootfs.img /data/ ; then
		echo "Error: Couldn't copy the rootfs to the device. Is the device connected?"
		exit 1
	fi
}

function flash_android_img() {
	if ! adb push $IMAGE_DIR/system.img /data/ ; then
		echo "Error: Couldn't copy the android image to the device. Is the device connected?"
		exit 1
	fi
}

function flash_dir() {
	adb push $ROOTFS_DIR/* /data/halium-rootfs/
}

function clean() {
	# Delete created files from last install
	rm -rf $ROOTFS_DIR $IMAGE_DIR
}

function clean_device() {
	# Make sure the device is in a clean state
	adb shell sync
}
