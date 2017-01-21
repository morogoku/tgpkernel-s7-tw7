# TGPKernel S7

A Custom Kernel for Samsung Galaxy S7 / S7 Edge, designed to be used with the TGP Custom ROM. 
The main purpose of this Kernel is to have a stock-like Kernel that runs on G930x (S7) 
variants, but capable of running the G935x (S7 Edge) Firmware. 


URL (S7 Forum): http://forum.xda-developers.com/showthread.php?t=3462897

URL (S7 Edge Forum): http://forum.xda-developers.com/showthread.php?t=3501571


Compiled using aarch64-cortex_a53-linux-gnueabi-GNU-6.3.0 Toolchain compiled by @Tkkg1994


## How to use
- Adjust the toolchain path in build.sh and Makefile to match the path on your system. 
- Run build.sh and follow the prompts.
- When finished, the new .img or .zip file will be created in the build directory.
- If Java is installed, the .zip files will be automatically signed.


## Credit and Thanks to the following:
- Samsung Open Source Release Center for the Source code (http://opensource.samsung.com)
- The Linux Kernel Archive for the Linux Patches (https://www.kernel.org)
- @Tkkg1994 or all his help and numerous code samples from his source
- @osm0sis for Android Image Kitchen
- @jesec for Fingerprint Fix
- @arter97 for regmap_bulk_read fix
- @lyapota for some Governors and Schedulers


