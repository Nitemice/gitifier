#!/bin/bash

PATHS=()

MODE='DIR'
REPODIR=
REPONAME=
REPO_INPROGRESS=
FILENAME=

IGNOREFILE=
MERGEDIRS=0
FLATTENDIRS=0

DEBUGPRINT=0


debugPrint()
{
    echo
    echo "PATHS: ${PATHS[*]}"
    echo "MODE: $MODE"
    echo "REPODIR: $REPODIR"
    echo "REPONAME: $REPONAME"
    echo "REPO_INPROGRESS: $REPO_INPROGRESS"
    echo "FILENAME: $FILENAME"
    echo "IGNOREFILE: $IGNOREFILE"
    echo "MERGEDIRS: $MERGEDIRS"
    echo "FLATTENDIRS: $FLATTENDIRS"
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
   -n: filename to use
   -m: merge directories
   -l: flatten directories
    "
    echo "$usage"
    echo "$1"

    # Show debug info
    if (( "$DEBUGPRINT" )); then
        debugPrint
    fi

    exit
}

parseArgs()
{
    looseOpts=()
    while [[ $# -gt 0 ]]; do
        opt="$1"
        case $opt in
            -f|--file)
                MODE='FILE'
                shift # past argument
                ;;
            -d|--dir)
                MODE='DIR'
                shift # past argument
                ;;
            -z|--archive)
                MODE='ZIP'
                shift # past argument
                ;;

            -i|--ignorefile|--gitignore)
                IGNOREFILE="$2"
                shift # past argument
                shift # past value
                ;;
            -n|--filename)
                FILENAME="$2"
                shift # past argument
                shift # past value
                ;;
            -m|--mergedirs)
                MERGEDIRS=1
                shift # past argument
                ;;
            -l|--flattendirs)
                FLATTENDIRS=1
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

    # Get the current directory (in Windows format, if possible)
    REPODIR="$( pwd -W || pwd )"

    # Set the FILENAME to the REPONAME if no FILENAME was specified
    if [[ -z "$FILENAME" ]]; then
        FILENAME="$REPONAME"
    fi

    # Set the REPO_INPROGRESS name
    REPO_INPROGRESS="$REPONAME"_inprogress
}

readInput()
{
    # Only print a prompt if nothing was piped in
    if [ ! -p /dev/stdin ]; then
        echo "Enter file paths:"
    fi

    # Stick it in an array
    while read -r line; do
        if [ -z "$line" ] || [[ "$line" =~ ^[[:space:]]*$ ]]; then
            break
        fi
        PATHS+=("$line")
    done

    if [[ ${#PATHS[@]} == 0 ]]; then
        usage "ERR: No paths provided"
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
    echo "$dotgit" > .git

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
    readarray fl < <(find . -mindepth 1 -maxdepth 1)
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
    cp -r "$dir/" "$REPO_INPROGRESS"

    pushd "$REPO_INPROGRESS"

    # Link in git files
    makeGitPointer

    # Make commit
    makeCommit "$dir"

    popd

    # Blow away folder
    rm -rf "$REPO_INPROGRESS"
}

addDirMerge()
{
    dir="$1"

    # Make a copy of the repo, to overwrite into
    mkdir "$REPO_INPROGRESS"

    pushd "$REPO_INPROGRESS"

    # Link in git files
    makeGitPointer

    # Restore files from git history
    git reset --hard

    popd

    # Make copy of dir, overwriting REPONAME_inprogress
    cp -fr "$dir/"* "$REPO_INPROGRESS"

    pushd "$REPO_INPROGRESS"

    # Make commit
    makeCommit "$dir"

    popd

    # Blow away folder
    rm -rf "$REPO_INPROGRESS"
}

addFile()
{
    file="$1"
    # Make copy of file, as FILENAME, in REPONAME directory
    cp -r "$file" "$REPONAME/$FILENAME"

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
        unzip "$zip" -d "$REPO_INPROGRESS"
    else
        mkdir "$REPO_INPROGRESS"
        tar -xf "$zip" -C "$REPO_INPROGRESS"
    fi

    pushd "$REPO_INPROGRESS"

    # Remove any nested directories
    if (( "$FLATTENDIRS" )); then
        flattenDir
    fi

    # Link in git files
    makeGitPointer

    # Make commit
    makeCommit "$zip"

    popd

    # Blow away folder
    rm -rf "$REPO_INPROGRESS"
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
    if [ "$MODE" = 'DIR' ]; then
        if (( "$MERGEDIRS" )); then
            addDirMerge "$currentpath"
        else
            addDir "$currentpath"
        fi
    elif [ "$MODE" = 'FILE' ]; then
        addFile "$currentpath"
    elif [ "$MODE" = 'ZIP' ]; then
        addZip "$currentpath"
    fi
done

if [ "$MODE" = 'DIR' ] || [ "$MODE" = 'ZIP' ]; then
    concludeRepo
fi