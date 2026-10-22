# Utility

## Scripts
- `Makefile` Makefile for CI and utility scripts
- `lint.mk` Script for Verilator Linter

## Lint
Requires Verilator. From the repository root:

```sh
make -C utils lint TOP=lc_decoder   # lint one registered top
make -C utils lint_all              # lint all registered tops
make -C utils lint_list             # list registered tops
```

For `lint`, `FILELIST=path/to/file.f` optionally overrides that top's
registered file list.

## Tests

Run every test suite Makefile directly under `ip/core/tests`:

```sh
make -C utils test_all
```

The `ci` target runs both the registered lint checks and these test suites.
