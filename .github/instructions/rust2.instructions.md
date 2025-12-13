---
applyTo: "**/*.rs"
name: Rust Development Standards
description: Idiomatic Rust with zero-cost abstractions, memory safety, and performance optimization
---

# Rust Development Standards

Goal: Memory-safe, performant, idiomatic Rust with zero runtime cost for abstractions.

## Core Rules

- **Safety**: Ownership + borrowing > GC; no `.unwrap()` in prod; `Result<T, E>` for errors
- **Performance**: Zero-cost abstractions; iterators > loops; stack > heap when possible
- **Idioms**: Traits for polymorphism; lifetimes for safety; `?` operator for errors
- **Format**: `cargo fmt`; Clippy strict (`-D warnings`); 2-space indent

## Standards

### Code Structure
```rust
// Module organization
mod error;    // Custom error types
mod model;    // Domain types
mod service;  // Business logic
mod storage;  // Persistence

// Public API
pub use error::{Error, Result};
pub use model::*;
```

### Error Handling
```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
  #[error("IO: {0}")]
  Io(#[from] std::io::Error),
  #[error("Not found: {0}")]
  NotFound(String),
}

pub type Result<T> = std::result::Result<T, AppError>;

// Never .unwrap() - use ?
fn process() -> Result<String> {
  let data = std::fs::read_to_string("file.txt")?;
  Ok(data.trim().to_string())
}
```

### Type Safety
```rust
// Newtype for domain safety (zero cost)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct UserId(u64);

// Const generics for compile-time validation
fn process<const N: usize>(data: [i32; N]) -> [i32; N] {
  data.map(|x| x * 2)
}

// Phantom types for state machines
struct Builder<State> {
  data: String,
  _marker: PhantomData<State>,
}
```

### Performance Patterns
```rust
// Iterators compile to tight loops (zero cost)
fn sum_evens(nums: &[i32]) -> i32 {
  nums.iter().filter(|&&n| n % 2 == 0).sum()
}

// Cow for conditional ownership
use std::borrow::Cow;
fn maybe_clone(s: &str, modify: bool) -> Cow<'_, str> {
  if modify {
    Cow::Owned(s.to_uppercase())
  } else {
    Cow::Borrowed(s)
  }
}

// SmallVec for small collections (stack first)
use smallvec::SmallVec;
let vec: SmallVec<[u32; 8]> = SmallVec::new();
```

## Toolchain

### Essential Commands
```bash
# Lint + format + test
cargo fmt && cargo clippy --all-targets -- -D warnings && cargo test

# Safety audit
cargo miri test && cargo audit

# Performance
cargo bench && cargo flamegraph

# Deps
cargo tree && cargo machete && cargo outdated
```

### Clippy Configuration
```toml
[lints.clippy]
all = "deny"
pedantic = "warn"
nursery = "warn"
cargo = "warn"
```

### Release Profile
```toml
[profile.release]
lto = true              # Link-time optimization
codegen-units = 1       # Better optimization
panic = "abort"         # Smaller binary
strip = true            # Remove debug symbols
```

## Patterns

### Traits for Polymorphism
```rust
trait Processor {
  fn process(&self, data: &str) -> Result<String>;
}

// Generic over trait
fn run<P: Processor>(p: &P, data: &str) -> Result<String> {
  p.process(data)
}
```

### Builder Pattern
```rust
#[derive(Default)]
struct Config {
  host: String,
  port: u16,
}

impl Config {
  fn builder() -> ConfigBuilder {
    ConfigBuilder::default()
  }
}

#[derive(Default)]
struct ConfigBuilder {
  host: Option<String>,
  port: Option<u16>,
}

impl ConfigBuilder {
  fn host(mut self, host: impl Into<String>) -> Self {
    self.host = Some(host.into());
    self
  }
  
  fn port(mut self, port: u16) -> Self {
    self.port = Some(port);
    self
  }
  
  fn build(self) -> Result<Config> {
    Ok(Config {
      host: self.host.ok_or(AppError::NotFound("host".into()))?,
      port: self.port.unwrap_or(8080),
    })
  }
}
```

### Async/Await
```rust
use tokio;

#[tokio::main]
async fn main() -> Result<()> {
  let result = fetch_data().await?;
  Ok(())
}

async fn fetch_data() -> Result<String> {
  let resp = reqwest::get("https://api.example.com")
    .await?
    .text()
    .await?;
  Ok(resp)
}
```

## Anti-Patterns

### Avoid
```rust
// ❌ .unwrap() in production
let x = some_option.unwrap();

// ❌ .clone() spam
let s = expensive_data.clone();

// ❌ Manual loops over iterators
let mut sum = 0;
for i in 0..10 {
  sum += i;
}

// ❌ String when &str suffices
fn process(s: String) -> String { ... }
```

### Prefer
```rust
// ✅ ? operator for errors
let x = some_option?;

// ✅ Borrowing over cloning
fn process(s: &str) -> String { ... }

// ✅ Iterators for expressiveness
let sum: i32 = (0..10).sum();

// ✅ &str for string slices
fn process(s: &str) -> &str { s.trim() }
```

## Testing

### Test Organization
```rust
#[cfg(test)]
mod tests {
  use super::*;
  
  #[test]
  fn test_process() {
    let result = process("input").unwrap();
    assert_eq!(result, "expected");
  }
  
  #[test]
  #[should_panic(expected = "not found")]
  fn test_error() {
    process_fail().unwrap();
  }
}
```

### Doc Tests
```rust
/// Process input and return uppercase
///
/// # Examples
/// ```
/// use myapp::process;
/// assert_eq!(process("hello"), "HELLO");
/// ```
pub fn process(s: &str) -> String {
  s.to_uppercase()
}
```

### Property-Based Testing
```rust
use proptest::prelude::*;

proptest! {
  #[test]
  fn test_reversible(s in "\\PC*") {
    let processed = process(&s);
    assert!(processed.len() >= s.len());
  }
}
```

## Memory & Performance

### Smart Pointer Selection
```rust
// Box: Heap allocation, single owner
let b: Box<[u8]> = vec![0; 1024].into_boxed_slice();

// Rc: Shared ownership, single-threaded
use std::rc::Rc;
let rc = Rc::new(data);

// Arc: Shared ownership, multi-threaded
use std::sync::Arc;
let arc = Arc::new(data);

// RefCell: Interior mutability, single-threaded
use std::cell::RefCell;
let cell = RefCell::new(data);
```

### Inline Hints
```rust
// Profile before applying!
#[inline]
fn small_fn(x: i32) -> i32 {
  x * 2
}

#[inline(always)]
fn critical_path(x: i32) -> i32 {
  x + 1
}
```

## Unsafe Code

### When Required
```rust
unsafe fn from_raw_parts(ptr: *const u8, len: usize) -> &'static [u8] {
  // SAFETY: Caller guarantees ptr is valid for len bytes
  // and the data lives for 'static lifetime
  std::slice::from_raw_parts(ptr, len)
}
```

### Minimize Surface
```rust
// Wrap unsafe in safe API
pub fn safe_wrapper(data: &[u8]) -> &[u8] {
  unsafe {
    // SAFETY: data is valid for the lifetime of the borrow
    from_raw_parts(data.as_ptr(), data.len())
  }
}
```

## Common Crates

### Essential
- `serde` - Serialization
- `tokio` - Async runtime
- `thiserror` - Error types
- `anyhow` - Error context

### Performance
- `rayon` - Data parallelism
- `crossbeam` - Concurrent data structures
- `smallvec` - Stack-first vectors
- `criterion` - Benchmarking

### Utilities
- `clap` - CLI parsing
- `env_logger` - Logging
- `reqwest` - HTTP client
- `sqlx` - Async SQL

## Quick Wins

### Fmt + Lint
```bash
cargo fmt && cargo clippy --fix
```

### Update Deps
```bash
cargo update && cargo audit
```

### Benchmark
```bash
cargo bench -- --save-baseline main
# Make changes
cargo bench -- --baseline main
```

### Profile
```bash
cargo build --release
perf record ./target/release/myapp
perf report
```
