all: host guest kvm

host:
	bash gen-initramfs.sh host/initramfs.txt

guest:
	bash gen-initramfs.sh guest/initramfs.txt

kvm:
	bash gen-initramfs.sh kvm/initramfs.txt

.PHONY: all host guest kvm