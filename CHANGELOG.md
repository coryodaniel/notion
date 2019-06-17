# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2019-06-17

### Added

- Default `@moduledoc` generation
- Support interpolating into custom `@moduledoc`
- Support for overriding and setting multiple typespecs
- Support for `event_value` type

### Changed

- `label` terminology to `metadata`

### Removed

- Arity 0 function in favor of supporting custom typespecs and `event_value` in additional to maps `event_measurements`

## [0.1.2] - 2019-06-16

### Added

- Default typespec of `map`, `map`
- Support for adding `@doc` to telemetry events
- Support for adding `@spec` to telemetry events
- Support for default metadata on all events
- `your_event_name/0` 0 arity function for dispatching an event
- `your_event_name/1` 1 arity function accepting `measurements` for dispatching an event. Uses default `metadata`
- `your_event_name/2` 2 arity function accepting `measurements` and `metadata` for dispatching an event. Merges metadata with default `metadata`
