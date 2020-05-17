# NoVC Gitifier

Tool for converting multiple versions of files into a git history.

Gitifier has three modes:

### Files Mode

For use with a series of versions of a single file.

The supplied name will be used both as the name of the repository folder, as well as the filename in the repository.

### Directories Mode

For use with a series of versions of directories.
This is the *default* mode.

### Archives Mode

For use with a series of tar or zip archives (files or directories).

This mode requires `tar` and/or `unzip`.

`-l` will flatten any single directories within the archive, i.e. if all the files in the archive are in a single folder, they will be moved to the root folder.


## Usage

```man
NoVC Gitifier
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
```


## Examples

For more examples for how to use Gitifier, see the `examples` folder.