# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.1] - 2023-11-04

### Changed

- Rename repository from "lua-binpack" to "binpack"
- BREAKING CHANGE: Move files from binpack subfolder into root directory. This change should make it easier to use Binpack as a Git submodule.

## [2.0.0] - 2023-10-22

### Added

- [LuaLS annotations](https://github.com/LuaLS/lua-language-server)
- Constructor functions `Container.new` and `Queue.new`
- `Cell` class, which represents a spatial cell in a container
- Method `Container.cells` to iterate over cells

### Changed

- BREAKING CHANGE: Rename `Queue.enqueue` to `Queue.add`

### Removed

- Internal `cells` module (replaced by the new `Cell` class)
- BREAKING CHANGE: Function `Queue.defaultOrderFunction` (replaced by local function)
- BREAKING CHANGE: Method `Container.getCellPosition` (replaced by `Cell.getPosition`)
- BREAKING CHANGE: Method `Container.getCellSize` (replaced by `Cell.getSize`)
- BREAKING CHANGE: Method `Container.getCellContentSize` (replaced by `Cell.getContentSize`)
- BREAKING CHANGE: Method `Container.getCellBoundings` (replaced by `Cell.getBoundingRect`)
- BREAKING CHANGE: Method `Container.getCellData`  (replaced by `Cell.getData`)
