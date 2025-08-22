# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Holo is a suite of routing protocols designed for high-scale, automation-driven networks. It's built in Rust with a focus on memory safety, reliability, and YANG-based configuration management. The project implements various routing protocols including BGP, OSPF, IS-IS, RIP, BFD, VRRP, and MPLS LDP.

## Build System and Commands

**Primary Build Commands:**
- `cargo build --release` - Build the main daemon and tools in release mode
- `cargo test` - Run all tests across the workspace
- `cargo clippy` - Run linter checks
- `cargo fmt` - Format code according to project style

**Fuzzing Commands:**
- `cd fuzz && ./fuzz-all.sh` - Run all fuzz targets
- `cd fuzz && ./generate-coverage-data.sh` - Generate coverage data for fuzzing

**Testing Commands:**
- `cargo test --workspace` - Run tests for all workspace members
- `cargo bench` - Run benchmarks (available in select crates like holo-bgp, holo-ldp, holo-ospf)

## Code Architecture

**Workspace Structure:**
The project uses a Cargo workspace with multiple crates organized by protocol and functionality:

- `holo-daemon` - Main entry point and daemon process
- `holo-northbound` - YANG-based configuration and management interface
- `holo-utils` - Shared utilities across all protocols
- `holo-routing` - Core routing table management
- `holo-{bgp,ospf,isis,rip,bfd,vrrp,ldp}` - Individual protocol implementations
- `holo-interface` - Network interface management
- `holo-system` - System-level integration
- `holo-yang` - YANG module definitions
- `holo-tools` - Development and debugging tools

**Key Architectural Patterns:**

1. **Async/Tokio-based:** All I/O and protocol logic uses async Rust with the Tokio runtime
2. **YANG Configuration:** All configuration is modeled using YANG schemas and processed via northbound interfaces
3. **Event-driven:** Protocols communicate through structured event messages
4. **Capabilities-based Security:** The daemon drops privileges after startup and uses Linux capabilities
5. **Modular Design:** Each protocol is isolated in its own crate with well-defined interfaces

**Important Modules:**
- `holo-daemon/src/main.rs` - Entry point with privilege dropping, logging setup, and northbound initialization
- `holo-northbound/src/lib.rs` - Core northbound processing for YANG operations
- `holo-utils/src/` - Shared utilities for networking, crypto, YANG processing, and protocol abstractions

**Configuration Management:**
- Static config: `/etc/holod.toml` (daemon startup parameters)
- Dynamic config: YANG-modeled configuration via gRPC/gNMI/CLI
- Database: Persistent storage using PickleDB

## Development Guidelines

**Code Style:**
- Uses `rustfmt` with custom configuration (`max_width = 80`, `edition = "2024"`)
- Workspace lints enforce `rust_2018_idioms` and forbid `unsafe_code`
- Import organization: `StdExternalCrate` with module-level granularity

**Memory Safety:**
- `unsafe_code` is forbidden at the workspace level
- All networking and system calls use safe Rust abstractions

**Testing:**
- Unit tests are co-located with source files
- Integration tests in separate `tests/` directories within each crate
- Fuzzing infrastructure in dedicated `fuzz/` directory with comprehensive corpus
- Benchmarking available for performance-critical protocol implementations

**Protocol Implementation Pattern:**
Each protocol crate follows a similar structure:
- `lib.rs` - Main protocol interface and public API
- `events.rs` - Event message definitions
- `tasks.rs` - Async task management
- `network.rs` - Network I/O handling
- `debug.rs` - Debugging and tracing support
- Protocol-specific modules (e.g., `neighbor.rs`, `packet.rs`, `rib.rs`)

## Dependencies and Features

**Core Dependencies:**
- `tokio` - Async runtime with full feature set
- `yang3` - YANG schema processing
- `tonic` - gRPC implementation
- `tracing` - Structured logging
- `serde` - Serialization framework

**Optional Features:**
- `tokio_console` - Tokio debugging console
- `io_uring` - Linux io_uring support for enhanced I/O performance

## Security Considerations

The daemon implements defense-in-depth security:
- Requires root privileges only for startup
- Drops to unprivileged `holo` user after initialization
- Uses Linux capabilities for minimal required permissions (`NET_ADMIN`, `NET_BIND_SERVICE`, `NET_RAW`)
- Memory safety guaranteed by Rust's type system

## Current Active Project

**ACTIVE: Cargo Fuzz Testing and Unit Test Creation Project**

There is an approved project ready for execution. See `FUZZ_TESTING_PLAN.md` for complete details.

**Project Goal:** Run cargo fuzz tests on earlier versions of the codebase, analyze crashes, and create unit tests that reproduce the crashes to verify fixes.

**Current Status:** Plan approved, ready for execution

**Key Files:**
- `FUZZ_TESTING_PLAN.md` - Comprehensive execution plan  
- `fuzz/` - Fuzzing infrastructure with existing artifacts
- `holo-bgp/tests/packet/decode.rs` - Working example from commit `91967074`

**Next Steps:** Start with historical commit fuzzing, analyze artifacts, create unit tests following proven methodology. All research and planning complete.