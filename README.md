# NoVC Gitifier

Tool for converting multiple versions of files into a git history.

Gitifier reads a list of files or directories from stdin, and adds each one,
in order, to a fresh git repository.

Gitifier has three modes:

### Files Mode

For use with a series of versions of a single file.

The supplied `reponame` will be used both as the name of the repository folder,
as well as the name of the file in the repository. A different filename can be
specified using `-n filename`.

### Directories Mode

For use with a series of versions of a single directory.
This is the *default* mode.

`-m` can be used when each directory only contains files that differ from
the previous directory.

### Archives Mode

For use with a series of tar or zip archives (files or directories).

This mode requires `tar` and/or `unzip`.

`-l` will flatten any single directories within the archive,
i.e. if all the files in the archive are in a single folder, they will be moved
to the root folder.


## Usage

```man
NoVC Gitifier
Usage: $0 [-f|-d|-z] reponame
       $0 -f [-n filename] reponame
       $0 -d [-i gitignore] [-m] reponame
       $0 -z [-i gitignore] [-l] reponame

   -f: files mode
   -d: directories mode
   -z: archives mode

   -i: .gitignore file to use
   -n: filename to use
   -m: merge directories
   -l: flatten directories
```


## Examples

For more examples for how to use Gitifier, see the `examples` folder.
