#!/bin/bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

cd $here

echo "Cleaning build-order-test"
make -j clean | sed -e 's/00./00X/g'
echo "Building build-order-test"
make -j | sed -e 's/00./00X/g'
