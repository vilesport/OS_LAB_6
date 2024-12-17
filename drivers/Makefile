obj-m = $(DRV).o
all:
	make -C ./../$(VER) M=$(PWD)/drivers/ modules
	gcc --static -o $(ELF) $(ELF).c

clean:
	make -C ./../$(VER) M=$(PWD)/drivers/ clean
	rm -rf $(ELF)
