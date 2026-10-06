# AGENTS.md

Guidance for AI agents working on the Simple Build System (SBS) repository.

## What this project is

SBS is a GNU make based build system for C/C++ projects on Linux. Users copy a
single file, `module.inc.mk`, into their project and write small "configuration
style" Makefiles that set `MODULE_*` variables and then `include` it. SBS
generates all the compile, link, clean and sub-module rules.

Design goals that must be preserved:

- **Single file distribution** - all functionality lives in `module.inc.mk`.
  Do not split it, and do not add dependencies beyond GNU make, bash,
  coreutils and gcc/g++ or clang/clang++ (`ar` for static libs, `tput` for the
  debug dump).
- **Simplicity for the user** - users should not need to write rules. New
  features are exposed as `MODULE_<SETTING>` variables with sane defaults.
- **Backward compatibility** of existing `MODULE_*` settings and of the
  printed output (tests assert exact stdout, see below).

## Repository layout

| Path | Purpose |
|------|---------|
| `module.inc.mk` | The entire build system. Version is `SBS_VERSION` near the top. |
| `Makefile.skel` | Reference of all user settings, each documented in a comment block. |
| `readme.MD` | User documentation / tutorial. |
| `TODO_0.6.txt` | Roadmap for the 0.6 release. |
| `run_test.sh` | Runs the test suite with XEET (`xeet run -c test/xeet.yaml "$@"`). |
| `test/xeet.yaml` | XEET test definitions. |
| `test/NNN_name/` | One directory per test (Makefiles, sources, scripts, expected output). |
| `test/hard_clean.sh` | Deletes every `obj/` and `lib/` directory under the current directory. |
| `.github/workflows/sanity.yml` | CI: runs `./run_test.sh` on pushes to `master` and `devel`. |

## How `module.inc.mk` works

Read the file in full before changing it; it is ~500 lines. Key points:

- **Naming**: user inputs are `MODULE_*`; internal variables are `SBS_*`;
  internal targets are `sbs_*`; `define` macros are CamelCase
  (`CreateSourceRules`, `GenSubModuleRule`, `SbsDbgTitle`, `SbsDbgVar`).
  Each `MODULE_X` is normally copied into an `SBS_X`, defaulted and validated,
  and only `SBS_X` is used afterwards.
- **Paths**: `SBS_PROJ_ROOT` is the directory of `module.inc.mk` (used for
  `MODULE_PROJECT_*` and `MODULE_ARTIFACT_DIR_REL`). `SBS_MODULE_PATH` is
  `$(shell pwd)`, the module directory (make is run inside it or with `-C`).
- **Binary section** (only when `MODULE_SRCS` is non-empty): resolves the
  compiler suite, binary type (`exec`/`shared`/`static`/`none`), linker (C++
  linker if any source has a C++ suffix), flavor flags (`dbg` adds
  `-g -O0 -DDEBUG=1 -D__DEBUG__=1`, `rel` adds `-O3`, unless
  `MODULE_USE_DEF_FLAV=0`), include/lib flags and overrides.
- **Objects** go to `<module>/obj/<flavor>/<source path>.o` (e.g.
  `obj/dbg/main.c.o`, plus `.d` dependency files). Sources outside the module
  directory keep their absolute path mirrored under `obj/<flavor>/`. The
  artifact goes to `obj/<flavor>/` unless `MODULE_ARTIFACT_DIR` is set.
- **Compile rules** are generated per suffix with
  `$(eval $(call CreateSourceRules,...))`; there are two rules per suffix
  (in-tree and out-of-tree sources). Remember `$$` escaping inside `define`
  blocks that are `eval`ed.
- **Every object and sub-module depends on `$(MAKEFILE_LIST)`**, so editing any
  Makefile triggers a rebuild.
- **Build ordering** is expressed purely through make prerequisites, not by
  recursive recipes. `GenSubModuleRule` is called in this order, and each layer
  depends on all the previous layers through the accumulating
  `SBS_BUILD_DEPS`: `MODULE_PRE_BUILD` -> `MODULE_PRE_SUB_MODULES` -> artifact
  together with `MODULE_SUB_MODULES` -> `MODULE_POST_SUB_MODULES` ->
  `MODULE_POST_BUILD`. Items within one layer have no order between them and
  run in parallel under `make -j`. Sub-modules are phony and built with
  `$(MAKE) -C <dir>`. Pre/post build targets get prerequisites only; the user
  supplies their recipes.
- **Clean ordering** follows the same idea: `MODULE_PRE_CLN` -> artifact clean
  plus `<submodule>__clean` targets -> `MODULE_POST_CLN`. Post-clean targets
  must never depend on `clean` itself (circular dependency).
- **Modules without sources** (pseudo modules that only have sub-modules)
  have an empty `SBS_ARTIFACT`. Guard any rule that uses `$(SBS_ARTIFACT)` as a
  target so you never create a rule with an empty target name.
- **Messages**: titles (`Building`/`Cleaning`/`Rebuilding '<name>'`) and the
  parallel rebuild warning are printed with `$(info ...)` at parse time. They
  can be suppressed through `MODULE_MSG_SUPRESS` (note the spelling) with the
  IDs `build_title` and `parallel_rebuild_wrn`. Non-verbose compile/link lines
  are `CC\t<file>`, `CXX\t<file>`, `LD\t<artifact>`, `AR\t<artifact>`;
  `MODULE_VERBOSE=1` prints the full commands instead (`SBS_Q` controls this).
- **Errors** for invalid settings are raised at parse time with `$(error ...)`.
- **Debug targets**: `sbs_version`, `sbs_dump_module_vars`,
  `sbs_dump_module_submodules`, `sbs_dump_module_build_steps`,
  `sbs_dump_module`, `sbs_dump_internals`, `sbs_dump_all`
  (`SBS_FORCE_DBG=1` shows empty variables, `SBS_DBG_TERMS=<str>` filters).
- `SHELL` is `/usr/bin/bash`, so recipes may use bash features.

### Coding style for `module.inc.mk`

- Recipes are indented with tabs. `ifeq`/`ifneq` blocks are **not**
  indented; long or nested blocks close with a comment, e.g.
  `endif # Executable or shared`.
- Use named constants for allowed values (`SBS_EXEC_BIN_TYPE`,
  `SBS_DBG_FLAV`, ...) and validate inputs with `$(filter ...)`.
- Assign with `:=` (simple expansion) unless lazy expansion is required.
- Keep lines at about 100 columns or less; comments are short, explain *why*.
- Prefer early validation and `$(error ...)` over deeply nested conditionals.

### Checklist when adding or changing a `MODULE_*` setting

1. Implement it in `module.inc.mk` (copy to an `SBS_*` variable, set a
   default, validate).
2. Document it in `Makefile.skel` using the same commented block format.
3. Document it in `readme.MD` if it is user facing.
4. Add it to `sbs_dump_module_vars` (and new `SBS_*` internals to
   `sbs_dump_internals`).
5. Add or update a test.

## Testing

Tests use [XEET](https://github.com/omercsp/xeet), which must be on `PATH`.
The tests include the repository's `module.inc.mk` through
`$(shell git rev-parse --show-toplevel)`, so they must be run inside the git
checkout.

```bash
./run_test.sh                 # full suite (gcc and clang, dbg and rel); takes a few seconds
./run_test.sh -t 006_deps     # a single test
./run_test.sh -g sanity       # a group
./run_test.sh -j 4            # parallel run
./run_test.sh --verbose       # more details on failures
```

Step outputs are stored in `test/xeet.out/<test>[:<permutation>]/<step>/stdout`.
`cd test && ./hard_clean.sh` removes leftover build output.

Test organization:

- Numbering: `0xx` core build mechanics, `1xx` binary artifacts and linking,
  `5xx` output, verbosity and warnings.
- `make_base` (abstract) runs `make clean`, `make` and `make clean` over a
  matrix of `flavor: [dbg, rel]` x `csuite: [gcc, clang]`, passing
  `MODULE_FLAV`/`MODULE_CSUITE` through the environment.
- `script_base` (abstract) runs `./run_test.sh` in the test directory and
  compares stdout with `expected_output.txt`. Stderr must be empty.
- Tests that share a directory between matrix permutations use a resource pool
  (`tutorial_dir`, `binaries_lock`) so they do not run concurrently.
- Some scripts generate files during the run (`Makefile` from
  `Makefile.base`, `header.h`, `Makefile.bad`) and remove them afterwards.
  These files are not tracked; never commit them.

To add a test, create `test/NNN_name/`, include the root `module.inc.mk`
the same way existing tests do, and add an entry to `test/xeet.yaml` that uses
`base: make_base` or `base: script_base` (or explicit steps), with
`groups: [sanity, <name>]`.

**Output is part of the contract.** Many tests compare the exact stdout
(titles, `CC`/`LD` lines, warnings, blank lines). Any change to printed
messages requires updating the matching `expected_output.txt` files and
`expected_stdout` entries in `test/xeet.yaml`. Test C code must compile without
warnings with both gcc and clang (`100_binaries` builds with `-Wall -Werror`).

## Known gaps between docs and code

Check the code before trusting the docs; the v0.6 documentation update is
still unfinished.

## Git conventions

- Branches: `master` (releases), `devel`, and release branches such as `v0.6`.
- Commit subjects use a topic prefix: `sbs:` for `module.inc.mk` changes,
  `test:` for tests, `doc:`/`readme:` for documentation, `github:` for CI.
- Build system changes and their tests usually go in separate commits (e.g.
  `sbs: warn on parallel rebuild` followed by `test: warn on parallel rebuild`).
- Commits are signed off (`Signed-off-by:`), and the body explains why the
  change was made.
- Build output (`obj/`, `lib/`, `test/xeet.out/`) is git-ignored.
