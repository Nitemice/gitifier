# Archive Mode Demo

```sh
find -maxdepth 1 -mindepth 1 -type f -name "*zip" -printf "%f\n" | ../../gitifier.sh -z foo
```

```sh
find -maxdepth 1 -mindepth 1 -type f -name "*tgz" -printf "%f\n" | ../../gitifier.sh -z foo
```

## Archive Mode with Directory Flattening

```sh
find -maxdepth 1 -mindepth 1 -type f -name "*zip" -printf "%f\n" | ../../gitifier.sh -z -l foo
```

```sh
find -maxdepth 1 -mindepth 1 -type f -name "*tgz" -printf "%f\n" | ../../gitifier.sh -z -l foo
```
