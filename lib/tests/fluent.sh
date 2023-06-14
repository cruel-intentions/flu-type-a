#!/usr/bin/env bash
#
# This is a copy of https://github.com/NixOS/nixpkgs/pull/234990
# But removed modules tests
#
# This script is used to test that the module system is working as expected.
# By default it test the version of nixpkgs which is defined in the NIX_PATH.
#

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s failglob inherit_errexit

# https://stackoverflow.com/a/246128/6605742
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "$DIR"/modules

pass=0
fail=0

evalConfig() {
    local attr=$1
    shift
    local script="import ./default.nix { modules = [ $* ];}"
    nix-instantiate --timeout 1 -E "$script" -A "$attr" --eval-only --show-trace --read-write-mode
}

reportFailure() {
    local attr=$1
    shift
    local script="import ./default.nix { modules = [ $* ];}"
    echo 2>&1 "$ nix-instantiate -E '$script' -A '$attr' --eval-only"
    evalConfig "$attr" "$@" || true
    ((++fail))
}

checkConfigOutput() {
    local outputContains=$1
    shift
    if evalConfig "$@" 2>/dev/null | grep --silent "$outputContains" ; then
        ((++pass))
    else
        echo 2>&1 "error: Expected result matching '$outputContains', while evaluating"
        reportFailure "$@"
    fi
}

checkConfigError() {
    local errorContains=$1
    local err=""
    shift
    if err="$(evalConfig "$@" 2>&1 >/dev/null)"; then
        echo 2>&1 "error: Expected error code, got exit code 0, while evaluating"
        reportFailure "$@"
    else
        if echo "$err" | grep -zP --silent "$errorContains" ; then
            ((++pass))
        else
            echo 2>&1 "error: Expected error matching '$errorContains', while evaluating"
            reportFailure "$@"
        fi
    fi
}

# simpleOptions helper
checkConfigOutput '^"ATT"$'         config.ATT.test                     ./fluent.nix
checkConfigOutput '^"ATT-ATT"$'     config.ATT-ATT.foo.test             ./fluent.nix '{ ATT-ATT.foo.test =          "ATT-ATT"; }'
checkConfigOutput '^"ATT-ENM"$'     config.ATT-ENM.test                 ./fluent.nix '{ ATT-ENM.test =              "ATT-ENM"; }'
checkConfigOutput '^"ATT-LST"$'     config.ATT-LST.test.0               ./fluent.nix '{ ATT-LST.test = [            "ATT-LST" ]; }'
checkConfigOutput '^"ATT-ONE"$'     config.ATT-ONE.test                 ./fluent.nix '{ ATT-ONE.test =              "ATT-ONE"; }'
checkConfigOutput '^"ATT-OPT-TYP"$' config.ATT-OPT.test.ATT-OPT-TYP     ./fluent.nix '{ ATT-OPT.test.ATT-OPT-TYP =  "ATT-OPT-TYP"; }'
checkConfigOutput '^"ENM"$'         config.ENM                          ./fluent.nix
checkConfigOutput '^"LST"$'         config.LST.0                        ./fluent.nix
checkConfigOutput '^"LST-ATT"$'     config.LST-ATT.0.test               ./fluent.nix '{ LST-ATT = [ { test =        "LST-ATT";} ]; }'
checkConfigOutput '^"LST-ENM"$'     config.LST-ENM.0                    ./fluent.nix '{ LST-ENM = [                 "LST-ENM" ]; }'
checkConfigOutput '^"LST-LST"$'     config.LST-LST.0.0                  ./fluent.nix '{ LST-LST = [ [               "LST-LST" ] ]; }'
checkConfigOutput '^"LST-ONE"$'     config.LST-ONE.0                    ./fluent.nix '{ LST-ONE = [                 "LST-ONE" ]; }'
checkConfigOutput '^"LST-OPT-TYP"$' config.LST-OPT.0.LST-OPT-TYP        ./fluent.nix '{ LST-OPT = [ { LST-OPT-TYP = "LST-OPT-TYP"; } ]; }'
checkConfigOutput '^"ONE"$'         config.ONE                          ./fluent.nix
checkConfigOutput '^"OPT-ATT"$'     config.OPT.OPT-ATT.test             ./fluent.nix
checkConfigOutput '^"OPT-ENM"$'     config.OPT.OPT-ENM                  ./fluent.nix
checkConfigOutput '^"OPT-LST"$'     config.OPT.OPT-LST.0                ./fluent.nix
checkConfigOutput '^"OPT-ONE"$'     config.OPT.OPT-ONE                  ./fluent.nix
checkConfigOutput '^"OPT-OPT-ATT"$' config.OPT.OPT-OPT.OPT-OPT-ATT.test ./fluent.nix
checkConfigOutput '^"OPT-OPT-ENM"$' config.OPT.OPT-OPT.OPT-OPT-ENM      ./fluent.nix
checkConfigOutput '^"OPT-OPT-LST"$' config.OPT.OPT-OPT.OPT-OPT-LST.0    ./fluent.nix
checkConfigOutput '^"OPT-OPT-ONE"$' config.OPT.OPT-OPT.OPT-OPT-ONE      ./fluent.nix
checkConfigOutput '^"OPT-OPT-TYP"$' config.OPT.OPT-OPT.OPT-OPT-TYP      ./fluent.nix
checkConfigOutput '^"OPT-TYP"$'     config.OPT.OPT-TYP                  ./fluent.nix
checkConfigOutput '^"TYP"$'         config.TYP                          ./fluent.nix
checkConfigOutput '^{ }$'           config.TYP-ATT                      ./fluent.nix
checkConfigOutput '^true$'          config.TYP-BOO                      ./fluent.nix
checkConfigOutput '^0$'             config.TYP-FLT                      ./fluent.nix
checkConfigOutput '^0$'             config.TYP-INT                      ./fluent.nix
checkConfigOutput '^"TYP-LST"$'     config.TYP-LST.0                    ./fluent.nix
checkConfigOutput '^null$'          config.TYP-NUL                      ./fluent.nix
checkConfigOutput '^"empty-file"$'  config.TYP-PKG.name                 ./fluent.nix
checkConfigOutput 'tests/modules$'  config.TYP-PTH                      ./fluent.nix
checkConfigOutput '^"TYP-STR"$'     config.TYP-STR                      ./fluent.nix
checkConfigOutput '^"MD doc"$'      options.TYP-DOC.description.text    ./fluent.nix


cat <<EOF
====== module tests ======
$pass Pass
$fail Fail
EOF

if [ "$fail" -ne 0 ]; then
    exit 1
fi
exit 0
