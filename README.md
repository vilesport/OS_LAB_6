# OS_LAB_6
---
* [Source tài liệu (201 - 203)](https://courses.uit.edu.vn/pluginfile.php/629879/mod_resource/content/1/Operating%20System%20Concepts%20by%20Abraham%20Silberschatz.pdf)

- More features were updated so that it's easier for debugging
- You can change your `linux kernel` version, `busybox` version and your driver name at the top of `run.sh`
- `run.sh` would help you for doing these things:
  - With no argument, it will run the machine, make sure that `kernel`, `busybox` and `compile` have to run at least 1 time before run
  - `build`   : build `linux kernel`, `busybox` and `compile` your driver in `drivers` folder
  - `kernel`  : build `linux kernel` only and copy `bzImage` to `files`
  - `busybox` : build `busybox` only, copy and setup everything for `initramfs`
  - `compile` : compile your driver in `drivers`
  - `help`: display this help
- Your driver will storaged in `drivers` folder as `.ko`. Just cd in there, `insmod` your drivers and debug
