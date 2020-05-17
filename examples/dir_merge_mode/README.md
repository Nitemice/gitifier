# Directories Mode Demo

```sh
find -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | ../../gitifier.sh output -m
```

## Directories Mode with GitIgnore

```sh
find -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | ../../gitifier.sh output -m -i gitignore.file
```
