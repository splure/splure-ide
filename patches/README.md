# Patches

Source changes to upstream VS Code go here as `*.patch` files. `scripts/prepare.sh` applies them in filename order, so prefix them with numbers (`010-…`, `020-…`).

To make one:

```sh
scripts/prepare.sh
cd vscode
# …edit files…
git diff > ../patches/010-my-change.patch
```

Keep patches small and few. Each one has to be re-applied on every upstream bump, and a theme or a `configurationDefaults` entry in `extensions/spluride-clean` survives updates far better than a source edit.
