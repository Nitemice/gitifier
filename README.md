# NoVC Gitifier

Tool for converting multiple versions of files into a git history

Gitifier has two modes:

## Directories Mode

Used when you have a series of versions of whole directories.

## Files Mode

Used when you have a series of versions of a single file.

## Usage

```man
NoVC Gitifier
Usage: $0 [-d|-f] reponame
       $0 -d [-i gitignore] [-m] reponame
       $0 -f reponame
   -d: directories mode
   -f: files mode
   -i: .gitignore file to use
   -m: merge directories
```
