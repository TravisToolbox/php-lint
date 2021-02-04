#!/usr/bin/env bash

set -eo pipefail

# -------------------------------------------------------------------------------- #
# Description                                                                      #
# -------------------------------------------------------------------------------- #
# This script will locate and process all relevant files within the given git      #
# repository. Errors will be stored and a final exit status used to show if a      #
# failure occured during the processing.                                           #
# -------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------- #
# Global Variables                                                                 #
# -------------------------------------------------------------------------------- #
# TEST_COMMAND - The command to execute to perform the test.                       #
# SEARCH_PATTERN - The pattern used by 'file' to match the correct file types.     #
# EXIT_VALUE - Used to store the script exit value - adjusted by the fail().       #
# -------------------------------------------------------------------------------- #
TEST_COMMAND='./vendor/bin/phplint'
FILE_TYPE_SEARCH_PATTERN='^PHP script'
FILE_NAME_SEARCH_PATTERN='\.php$'
EXIT_VALUE=0

BANNER="Scanning all php code with phplint"

# -------------------------------------------------------------------------------- #
# Success                                                                          #
# -------------------------------------------------------------------------------- #
# UX - Show the user that the processing of a specific file was successful.        #
# -------------------------------------------------------------------------------- #
success()
{
    printf ' [  \033[00;32mOK\033[0m  ] Linting successful for %s\n' "$1"
}

# -------------------------------------------------------------------------------- #
# Fail                                                                             #
# -------------------------------------------------------------------------------- #
# UX - Show the user that the processing of a specific file failed and adjust the  #
# EXIT_VALUE to record this.                                                       #
# -------------------------------------------------------------------------------- #
fail()
{
    printf ' [ \033[0;31mFAIL\033[0m ] Linting failed for %s\n' "$1"
    echo "$2"
    EXIT_VALUE=1
}

# -------------------------------------------------------------------------------- #
# Skip                                                                             #
# -------------------------------------------------------------------------------- #
# UX - Show the user that the processing of a specific file was skipped.           #
# -------------------------------------------------------------------------------- #
skip()
{
    printf ' [ \033[00;36mSkip\033[0m ] Skipping %s\n' "$1"
}

# -------------------------------------------------------------------------------- #
# Check                                                                            #
# -------------------------------------------------------------------------------- #
# Check a specific file.                                                           #
#                                                                                  #
# Due to how reek works we have to 'force' scanning file files that dont end in rb #
#                                                                                  #
# -------------------------------------------------------------------------------- #
check()
{
    local filename="$1"
    local errors

    # shellcheck disable=SC2094,SC2086
    if errors=$(${TEST_COMMAND} ${filename} < ${filename}); then
        success "${filename}"
    else
        fail "${filename}" "${errors}"
    fi
}

# -------------------------------------------------------------------------------- #
# Scan Files                                                                       #
# -------------------------------------------------------------------------------- #
# Locate all of the relevant files within the repo and process compatible ones.    #
# -------------------------------------------------------------------------------- #
scan_files()
{
    echo "${BANNER}"

    while IFS= read -r filename
    do
        # shellcheck disable=SC2053
        if file -b "${filename}" | grep -qE "${FILE_TYPE_SEARCH_PATTERN}"; then
            check "${filename}"
        elif [[ ${filename} =~ ${FILE_NAME_SEARCH_PATTERN} ]]; then
            check "${filename}"
        fi
    done < <(git ls-files)

    exit $EXIT_VALUE
}

# -------------------------------------------------------------------------------- #
# Main()                                                                           #
# -------------------------------------------------------------------------------- #
# This is the actual 'script' and the functions/sub routines are called in order.  #
# -------------------------------------------------------------------------------- #

scan_files

# -------------------------------------------------------------------------------- #
# End of Script                                                                    #
# -------------------------------------------------------------------------------- #
# This is the end - nothing more to see here.                                      #
# -------------------------------------------------------------------------------- #
