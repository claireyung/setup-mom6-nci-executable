# setup-mom6-nci
This is a fork of Angus' [mom6-ninja-nci](https://github.com/angus-g/mom6-ninja-nci) repo, with updates to work with the latest codebase available for running MOM6 and SIS2. Unlike the original repository, there's a `src` folder here which contains submodules corresponding to versions of each respective piece of source code that works with the compile scripts. Previously, one needed to clone the `https://github.com/NOAA-GFDL/MOM6-examples` repo, but as the code here was updated parts of the compile script would break. This repo serves to keep both pieces of the puzzle (compile scripts and coressponding source code) together. 

The rest of the readme is an updated version of Angus' original.

Painless shell scripts to set up a ninja build of MOM6 on NCI with Intel compilers. As prerequisites, I recommend you have the latest `intel-compiler` module loaded, `netcdf`, and a modern version of OpenMPI (4.0.x).

## Setup
1. Clone this repository. Keep in mind that this directory will fill up fith objects, files and executables so putting it in scratch might be a good idea
2. Inside the `setup-mom6-nci` repository run `git submodule update --init --recursive` to pull down all of the source code
3. Run `./gen_build.sh` to generate the overall config file for compiler flags (you may edit the `config.ninja` file afterwards to change these)
4. Make sure you have the [ninja](https://github.com/ninja-build/ninja/releases) executable somewhere in your `PATH`

### If modifying the source code
In this case you'll not want the source code on Scratch! Instead, it's easiest to move the `src` directory somewhere safe and replace it with a symlink `ln -s path_to_src setup-mom6/src`

## Building FMS
The `shared` subdirectory is to build the FMS library against which MOM6 is linked.

1. In `shared`, run `./gen_build.sh` to generate the build script
2. (Optional) Check `build.ninja` seems sensibly populated
3. *Build it!* Run `ninja`

## Building MOM6
The `ocean_only_symmetric` subdirectory contains configuration for the ocean only (i.e. no sea ice or other coupling), symmetric C-grid, dynamic memory version of the model. Build steps are identical to FMS:

1. In `ocean_only_symmetric`, run `./gen_build.sh` to generate the build script
2. (Optional) Check `build.ninja` seems sensibly populated
3. *Build it!* Run `ninja`

You now have a `MOM6` executable.

## Updating the source
Most of the time, you will only be tweaking MOM6 source, so only MOM6 itself needs to be rebuilt. In many cases, changes to the source won't change the dependency order, so you can just re-run `ninja`, which will recompile only what is necessary, as any build system would. If the dependency order is changed (usually from added `use` statements here and there), re-run `./gen_build.sh`.

## Symmetric? 
This refers to the memory configuration. Symmetric means that, say, the eastward and westwards boundaries both end with a cell edge. In a nonsymmetric case, one would end with a cell edge, and the other with a cell centre. For regional configurations you need symmetric memory. If you want to change this, then simply replace `symmetric` with `nonsymmetric` where in the `gen_build.sh` files. 
