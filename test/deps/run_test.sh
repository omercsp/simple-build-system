#!/bin/bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
flav=${MODULE_FLAV:-dbg}
prog=obj/${flav}/$(basename ${here})
makefile_base=Makefile.base
makefile=Makefile
header_base=header.h.base
header=header.h

_find_dep_files()
{
	local files=$(find ${here}/obj/${flav} -name *.d)
	if [[ -z ${files} ]]; then
		return 1
	else
		return 0
	fi
}

cd ${here}
cp ${makefile_base} ${makefile}
cp ${header_base} ${header}

make clean > /dev/null
make > /dev/null

if ! _find_dep_files; then
	echo "There are no dep files after build with deps..."
	exit 1
fi
${prog}

sed -e 's/my macro/my other macro/' ${header_base} > ${header}
make > /dev/null
${prog} # build should be affected, and output changed

make clean > /dev/null
if _find_dep_files; then
	echo "There are still dep files after clean..."
	exit 1
fi

cp ${header_base} ${header}
sed -e 's/MODULE_DEP_FLAGS := 1/MODULE_DEP_FLAGS := 0/' ${makefile_base} > ${makefile}
make > /dev/null
if _find_dep_files; then
	echo "There are still dep files after build with no deps"
	exit 1
fi
${prog}


sed -e 's/my macro/my other macro/' ${header_base} > ${header}
make > /dev/null
${prog} # build should not be affected, and output unchanged

rm ${makefile}
rm ${header}

