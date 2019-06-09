# Files Mode Demo

```sh
find -maxdepth 1 -mindepth 1 -type f -name "doc*" -printf "%f\n" | ../../gitifier.sh -f doc.md
```
