# NoVC Gitifier

Tool for converting multiple versions of files into a git history

Gitifier has three modes:

### Directories Mode

Used when you have a series of versions of whole directories.

### Files Mode

Used when you have a series of versions of a single file.

### Archives Mode

Used when you have a series of versions of archives of files or directories.

## Usage

```man
NoVC Gitifier
Usage: $0 [-d|-f|-z] reponame
       $0 -d [-i gitignore] [-m] reponame
       $0 -z [-i gitignore] [-l] reponame
       $0 -f reponame

   -d: directories mode
   -f: files mode
   -z: archives mode

   -i: .gitignore file to use
   -m: merge directories
   -l: flatten directories
```
