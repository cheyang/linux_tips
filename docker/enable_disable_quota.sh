#!/bin/bash

function do_enable_quota() {
    local ID=$1
    echo $ID
    local QUOTA_MB=$2
    local MOUNT_ID=`cat /var/lib/docker/image/aufs/layerdb/mounts/$ID/mount-id`

    local LOOPBACK=/var/lib/docker/aufs/diff/${MOUNT_ID}-loopback
    local LOOPBACK_MOUNT=/var/lib/docker/aufs/diff/${MOUNT_ID}-loopback-mount
    local DIFF=/var/lib/docker/aufs/diff/$MOUNT_ID

    docker stop -t=0 $ID
    dd of=$LOOPBACK bs=1M seek=$QUOTA_MB count=0
    mkfs.ext4 -F $LOOPBACK
    mkdir -p $LOOPBACK_MOUNT
    mount -t ext4 -n -o loop,rw $LOOPBACK $LOOPBACK_MOUNT
    rsync -rtv $DIFF/ $LOOPBACK_MOUNT/
    rm -rf $DIFF
    mkdir -p $DIFF
    umount $LOOPBACK_MOUNT
    rm -rf $LOOPBACK_MOUNT
    mount -t ext4 -n -o loop,rw $LOOPBACK $DIFF
    docker start $ID    
}

do_enable_quota $@