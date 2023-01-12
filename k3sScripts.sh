#!/bin/bash
myregistry="registry.localhost"
myregistryport="5000"

usage () { echo "script usage: $(basename $0) [-c] [-d]"; }

while getopts 'cd' OPTION; do
    case "${OPTION}" in
        c)
            echo "you have supplied the -c 'create' option"
            myregistryport="5000"
            k3d registry create ${myregistry} --port ${myregistryport}
            k3d cluster create --registry-use k3d-${myregistry}:${myregistryport} -p "8080:80@loadbalancer" --agents 2
            # k3d cluster create --registry-config my-registries.yaml -p "8080:80@loadbalancer" --agents 2
            ;;
        d)
            echo "you have supplied the -d 'destroy' option"
            k3d cluster delete k3s-default
            k3d registry delete k3d-${myregistry}
            ;;
        ?)
            usage >&2
            exit 1
            ;;
    esac
done
if [ $OPTIND -eq 1 ]; then usage ; fi
shift "$(($OPTIND -1))"
