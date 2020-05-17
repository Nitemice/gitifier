#!/bin/bash

PATHS=[]
REPONAME=""
REPODIR=""
MODE=DIR
IGNOREFILE=""
MERGEDIRS=0
FLATTENZIP=0
DEBUGPRINT=0

debugPrint()
{
    echo "PATHS: ${PATHS[*]}"
    echo "REPONAME: $REPONAME"
    echo "REPODIR: $REPODIR"
    echo "MODE: $MODE"
    echo "IGNOREFILE: $IGNOREFILE"
    echo "MERGEDIRS: $MERGEDIRS"
    echo "FLATTENZIP: $FLATTENZIP"
}

usage()
{
    usage="NoVC Gitifier
Usage: $0 [-f|-d|-z] reponame
       $0 -f reponame
       $0 -d [-i gitignore] [-m] reponame
       $0 -z [-i gitignore] [-l] reponame

   -f: files mode
   -d: directories mode
   -z: archives mode

   -i: .gitignore file to use
   -m: merge directories
   -l: flatten directories
    "
    echo "$usage"
    echo "$1"
    exit
}

parseArgs()
{
    looseOpts=()
    while [[ $# -gt 0 ]]; do
        opt="$1"
        case $opt in
            -d|--dir)
                MODE=DIR
                shift # past argument
                ;;
            -f|--file)
                MODE=FILE
                shift # past argument
                ;;
            -z|--archive)
                MODE=ZIP
                shift # past argument
                ;;
            -i|--ignorefile|--gitignore)
                IGNOREFILE="$2"
                shift # past argument
                shift # past value
                ;;
            -m|--mergedirs)
                MERGEDIRS=1
                shift # past argument
                ;;
            -l|--flattenZip)
                FLATTENZIP=1
                shift # past argument
                ;;
            -e|--debug)
                DEBUGPRINT=1
                shift # past argument
                ;;
            *) # unknown option
                looseOpts+=("$1") # save it in an array for later
                shift # past argument
                ;;
        esac
    done

    # Grab REPONAME from end of supplied arguments
    if [[ "${#looseOpts[@]}" -gt 0 ]]; then
        REPONAME="${looseOpts[-1]}"
    else
        usage "ERR: No repo name"
    fi
}

readInput()
{
    # Check if they piped anything in
    if [ -p /dev/stdin ]; then
        # Stick it in an array
        readarray PATHS
        if [[ ${#PATHS[*]} == 0 ]]; then
            usage "ERR: No paths"
        fi
    else
        usage "ERR: No input"
    fi
}

initRepo()
{
    # Make REPONAME directory
    mkdir "$REPONAME" || usage "ERR: $REPONAME exists"

    # Add any ignore file
    if [[ -f "$IGNOREFILE" ]]; then
        cp "$IGNOREFILE" "$REPONAME"/.gitignore
    fi

    # Get the current directory (in Windows format, if possible)
    REPODIR="$(pwd -W || pwd )"

    # Initialise the git repo
    pushd "$REPONAME"
    git init
    popd
}

concludeRepo()
{
    # Restore files from git history
    pushd "$REPONAME"
    git reset --hard
    popd
}

makeGitPointer()
{
    # Link this directory back to the main repo
    # We're doing it this hacky way,
    # because re-init'ing against the repo messes it up.
    dotgit="gitdir: $REPODIR/$REPONAME/.git"
    echo $dotgit > .git

    # Add gitignore file
    if [[ -f "$REPODIR/$REPONAME/.gitignore" ]]; then
        cp "$REPODIR/$REPONAME/.gitignore" .gitignore
    fi
}

makeCommit()
{
    # Commit all changed files
    git add --all
    git commit -m "$1"
}

flattenDir()
{
    # If there's only one directory in the folder,
    # move everything out of it, and recurse
    local fl=($(find -mindepth 1 -maxdepth 1))
    if (( ${#fl[@]} == 1 )) && [[ -d "${fl[0]}" ]]; then
        mv "${fl[0]}"/* .
        rmdir "${fl[0]}"
        flattenDir
    fi
}

addDir()
{
    dir="$1"
    # Make copy of dir, under REPONAME_inprogress
    cp -r "$dir/" "$REPONAME"_inprogress

    pushd "$REPONAME"_inprogress

    # Link in git files
    makeGitPointer

    # Make commit
    makeCommit "$dir"
    
    popd

    # Blow away folder
    rm -rf "$REPONAME"_inprogress
}

addFile()
{
    file="$1"
    # Make copy of file, as REPONAME, in REPONAME directory
    cp -r "$file" "$REPONAME/$REPONAME"

    pushd "$REPONAME"

    # Make commit
    makeCommit "$file"
    
    popd
}

addZip()
{
    zip="$1"
    # Unpack zip into dir, under REPONAME_inprogress
    if [[ $zip == *.zip ]]; then
        unzip "$zip" -d "$REPONAME"_inprogress
    else
        mkdir "$REPONAME"_inprogress
        tar -xf "$zip" -C "$REPONAME"_inprogress
    fi

    pushd "$REPONAME"_inprogress

    # Remove any nested directories
    if (( "$FLATTENZIP" )); then
        flattenDir
    fi

    # Link in git files
    makeGitPointer

    # Make commit
    makeCommit "$zip"
    
    popd

    # Blow away folder
    rm -rf "$REPONAME"_inprogress
}

# Parse arguments
parseArgs $@

# Read the input list of files/folders to gitify
readInput

# Initialise repo
initRepo

# Show debug info
if (( "$DEBUGPRINT" )); then
    debugPrint
fi

# Iterate through the given PATHS
for ix in ${!PATHS[*]}; do
    currentpath=${PATHS[$ix]//[$'\t\r\n']}
    echo "Adding $currentpath to git repo"
    if [ "$MODE" = "DIR" ]; then
        addDir "$currentpath"
    elif [ "$MODE" = "FILE" ]; then
        addFile "$currentpath"
    elif [ "$MODE" = "ZIP" ]; then
        addZip "$currentpath"
    fi
done

if [ "$MODE" = "DIR" ] || [ "$MODE" = "ZIP" ]; then
    concludeRepo
fi