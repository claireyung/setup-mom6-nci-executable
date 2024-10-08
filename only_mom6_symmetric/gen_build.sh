#!/bin/bash

# source config variables
. ../gen_build.sh
srcdir=../src
cat << 'EOF' > build.ninja
include ../config.ninja

incflags = $incflags -I../shared -I${srcdir}/MOM6/config_src/memory/dynamic_symmetric -I${srcdir}/MOM6/src/framework
ldflags = -lnetcdff -lnetcdf -L../shared -lfms
fflags = $fflags_opt
cppdefs = $cppdefs -Duse_AM3_physics -D_USE_LEGACY_LAND_ -Duse_deprecated_io -Duse_netcdf
EOF

# lists of source files
fsrc_files=($(find -L ${srcdir}/MOM6/src -iname '*.f90'))
fsrc_files+=($(find -L ${srcdir}/MOM6/config_src/external -iname '*.f90'))
fsrc_files+=($(find -L ${srcdir}/MOM6/config_src/drivers/solo_driver -iname '*.f90'))
fsrc_files+=($(find -L ${srcdir}/MOM6/config_src/infra/FMS2 -iname '*.f90'))
objs=()

# build module provides for fortran files
declare -A modules products
for file in "${fsrc_files[@]}"; do
    provided=$(sed -rn '/\bprocedure\b/I! s/^\s*module\s+(\w+).*/\1/ip' "$file" | tr '[:upper:]' '[:lower:]')
    gen_nfile "$file"
    for m in $provided; do
	modules[$m]="$nfile"
	products[$file]+="${m}.mod "
    done
done

# fortran file rules
for file in "${fsrc_files[@]}"; do
    deps=$(sed -rn 's/^\s*use\s+(\w+).*/\1/ip' "$file" | uniq | tr '[:upper:]' '[:lower:]')
    mods=()
    srcs=()
    gen_nfile "$file"

    for dep in $deps; do
	if [[ ! -z ${modules[$dep]} && ${modules[$dep]} != $nfile ]]; then
	    srcs+=("${modules[$dep]}")
	    mods+=("$(basename "${modules[$dep]%.*}").o")
	fi
    done

    obj="$(basename "${file%.*}").o"
    objs+=("$obj")

    printf 'build %s %s: fc %s' "$obj" "${products[$file]}" "$nfile" >> build.ninja

    # print source files and modules, if any
    printf '%s' "${srcs[@]+ | }" >> build.ninja
    printf '%s ' "${srcs[@]}" >> build.ninja
    printf '%s' "${mods[@]+ || }" >> build.ninja
    printf '%s ' "${mods[@]}" >> build.ninja
    printf '\n' >> build.ninja
done

printf 'build MOM6: link ' >> build.ninja
printf '%s ' "${objs[@]}" >> build.ninja
printf '\n' >> build.ninja
