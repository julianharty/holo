# Cargo Fuzz Testing and Unit Test Creation Plan

## Project Context
This is the Holo routing protocol suite codebase. We're implementing a systematic approach to run cargo fuzz tests on earlier versions, analyze crashes, and convert them into reproducible unit tests.

## Current Status
- **Repository**: `/home/julian/NLnet-projects/julianharty-holo`
- **Current HEAD**: `b53dd1c8` (Merge pull request #84 from Paul-weqe/remove-chroot-readme)
- **Analysis completed**: Plan developed but not yet executed
- **Ready for execution**: All research and planning complete

## Key Resources Available

### Existing Evidence
- **Working example**: Commit `91967074` shows proven methodology
  - File: `holo-bgp/tests/packet/decode.rs` 
  - Shows how to convert fuzz crash to unit test
- **Existing artifact**: `fuzz/artifacts/bgp_attr_as_path_decode/crash-da39a3ee5e6b4b0d3255bfef95601890afd80709`
- **External crashes**: GitHub issue #71 has additional crash files
- **Fixed panics**: 
  - Commit `7320b722`: OSPF panic fixes (Aug 8, 2025)
  - Commit `60e484b5`: IS-IS panic fixes (Aug 5, 2025)

### Fuzz Infrastructure
- **Fuzz targets**: 56+ targets in `fuzz/fuzz_targets/` covering all protocols
- **Run script**: `fuzz/fuzz-all.sh` runs all targets (default 1200s each)
- **Config**: `fuzz/Cargo.toml` defines all fuzz binaries

## Strategic Implementation Plan

### Phase 1: Target Commit Selection
**Key commits to fuzz (chronological order):**
1. **Pre-panic-fix commits** (before `60e484b5` and `7320b722`)
2. **`330f48f3`**: Removed `BytesArbitrary` wrapper (potential API changes)
3. **Mid-May 2025 commits**: Around original failing test timeframe
4. **Current HEAD**: For fix verification

### Phase 2: Systematic Fuzzing Process
```bash
# For each target commit:
git checkout <target-commit>
cd fuzz
./fuzz-all.sh 1200  # 20 minutes per target
# Document artifacts in timestamped directories
```

### Phase 3: Crash Analysis and Reproduction
Following commit `91967074` methodology:
1. **Test crash**: `cargo +nightly fuzz run <target-name> <artifact-path>`
2. **Add debug logging**: `eprintln!("Crash data: {}", hex::encode(data));`
3. **Extract crash bytes**: Use for hardcoded unit tests

### Phase 4: Unit Test Creation Pattern
```rust
#[test]
fn reproduce_crash_<protocol>_<issue_type>() {
    let mut u = Unstructured::new(&[<crash_bytes>]);
    // ... decode attempt that should handle gracefully
}
```

## Critical Implementation Details

### Fuzz Target Instrumentation
**Add to fuzz targets** in `fuzz/fuzz_targets/*/`:
- Debug logging: `eprintln!("{}", hex::encode(data));`
- State tracking before decode calls
- Input parameter logging

### Artifact Organization
- Create dated subdirectories for each commit's crashes
- Cross-reference with GitHub issue #71 crashes
- Maintain mapping from artifact → unit test

### Cross-version Testing Strategy
1. **Create unit tests** from historical crashes
2. **Test against multiple commits** to track when fixes were applied
3. **Update tests for API changes** between versions
4. **Verify current HEAD** passes all tests

## Expected Patterns and Outcomes

### Likely Crash Categories
Based on existing fixes:
- Buffer underflows/overflows
- Missing length validations
- Prefix length validation issues (OSPFv3, IS-IS)
- TLV parsing errors
- MPLS label parsing bugs

### Success Metrics
- **Crash collection**: Multiple artifacts from historical commits
- **Unit test coverage**: Tests for each major crash type
- **Fix verification**: Tests pass on current HEAD
- **Pattern identification**: Common vulnerability types documented

## Future Session Notes

### Immediate Next Steps
1. **Start with commit `330f48f3`**: Good baseline before major fixes
2. **Run extended fuzzing**: Use 20+ minute sessions per target
3. **Focus on BGP first**: Most artifacts already exist there
4. **Download GitHub issue #71 crashes**: Supplement local findings

### Development Environment Setup
```bash
# Ensure cargo-fuzz is installed
cargo install cargo-fuzz

# Verify fuzz targets work
cd fuzz && cargo fuzz list

# Test existing artifact
cargo +nightly fuzz run bgp_attr_as_path_decode \
  artifacts/bgp_attr_as_path_decode/crash-da39a3ee5e6b4b0d3255bfef95601890afd80709
```

### Key Files to Monitor
- `fuzz/artifacts/` - New crashes will appear here
- `holo-*/tests/packet/` - Where new unit tests belong  
- `fuzz/fuzz_targets/*/` - Where to add instrumentation

## Important Context for Future Self

### User's Requirements
- Run fuzz tests on **earlier versions** of codebase
- Create unit tests that **reproduce crashes**
- Test against **more recent commits** including HEAD
- Identify which flaws are **fixed vs still present**
- May need to **update unit tests** for newer commits (API changes)

### Proven Working Method
The commit `91967074` shows this works:
- Fuzz test finds crash → artifact file created
- Use `cargo fuzz run` with artifact to reproduce  
- Add debug logging to see crash data
- Convert fuzz target logic to unit test with hardcoded data
- Test passes on current HEAD (showing bug was fixed)

### Repository State
- **Clean working directory** 
- **No pending changes**
- **All previous analysis completed**
- **Ready for execution**

## Execution Authorization
User has **approved this plan** and wants implementation to proceed. All research and planning is complete - move directly to execution when session resumes.