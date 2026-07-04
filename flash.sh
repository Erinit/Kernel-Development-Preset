#!/bin/bash
# Nuclear Option: Pure Legacy GRUB Installation for TetrisOS

# Unmount and prep the drive (Assuming /dev/sdb - ALWAYS DOUBLE CHECK!)
sudo umount /dev/sdb*
sudo partprobe /dev/sdb

# 1. Create the classic MBR partition table
sudo parted -s /dev/sdb mklabel msdos

# 2. Create the primary partition
sudo parted -s /dev/sdb mkpart primary fat32 1MiB 100%

# 3. Inform the kernel one more time just to be safe
sudo partprobe /dev/sdb

# 4. Format the partition to FAT32
sudo mkfs.fat -F32 /dev/sdb1

# 5. Mount the new partition
sudo mount /dev/sdb1 /mnt

# 6. Install pure Legacy GRUB to the Master Boot Record
sudo grub-install --target=i386-pc --boot-directory=/mnt/boot /dev/sdb

# 7. Copy the compiled kernel
sudo cp myos.bin /mnt/boot/myos.bin

# 8. Generate the text-mode GRUB configuration
sudo bash -c 'cat > /mnt/boot/grub/grub.cfg <<EOF
terminal_input console
terminal_output console
set gfxpayload=text

menuentry "TetrisOS (Pure Legacy)" {
    multiboot /boot/myos.bin
    boot
}
EOF'

# 9. Cleanup and flush to disk
sudo umount /mnt
sync
echo "TetrisOS successfully flashed to /dev/sdb in pure legacy mode."