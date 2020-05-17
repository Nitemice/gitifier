# Archive Mode Demo

```sh
find -maxdepth 1 -mindepth 1 -name "*tgz" -printf "%f\n" -o -name "*zip" -printf "%f\n" | ../../gitifier.sh -z output
```

## Archive Mode with Directory Flattening

```sh
find -maxdepth 1 -mindepth 1 -name "*tgz" -printf "%f\n" -o -name "*zip" -printf "%f\n" | ../../gitifier.sh -z -l output
```

# Archive Mode Demo with GitIgnore

```sh
find -maxdepth 1 -mindepth 1 -name "*tgz" -printf "%f\n" -o -name "*zip" -printf "%f\n" | ../../gitifier.sh -z output -i gitignore.file
```
