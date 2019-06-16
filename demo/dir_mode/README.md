# Directories Mode Demo

```sh
find -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | ../../gitifier.sh foo
```

## Directories Mode with GitIgnore

```sh
find -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | ../../gitifier.sh foo -i gitignore.file
```
