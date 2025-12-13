---
description: 'Rust programming language coding conventions and best practices'
applyTo: '**/*.rs'
---

# Rust Coding Conventions and Best Practices

Follow idiomatic Rust practices and community standards when writing Rust code. These instructions are based on [The Rust Book](https://doc.rust-lang.org/book/), [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/), [RFC 430 naming conventions](https://github.com/rust-lang/rfcs/blob/master/text/0430-finalizing-naming-conventions.md), and the broader Rust community.

**Goal**: Memory-safe, performant, idiomatic Rust with zero runtime cost for abstractions.

## Core Rules

- **Safety**: Ownership + borrowing > GC; no `.unwrap()` in prod; `Result<T, E>` for errors
- **Performance**: Zero-cost abstractions; iterators > loops; stack > heap when possible
- **Idioms**: Traits for polymorphism; lifetimes for safety; `?` operator for errors
- **Format**: `cargo fmt`; Clippy strict (`-D warnings`); lines <100 chars; 2-space indent
- **Quality**: Code compiles without warnings; comprehensive tests; rustdoc for public APIs

## General Instructions

- Always prioritize readability, safety, and maintainability
- Use strong typing and leverage Rust's ownership system for memory safety
- Break down complex functions into smaller, more manageable functions
- For algorithm-related code, include explanations of the approach used
- Write code with good maintainability practices, including comments on why certain design decisions were made
- Handle errors gracefully using `Result<T, E>` and provide meaningful error messages
- For external dependencies, mention their usage and purpose in documentation
- Use consistent naming conventions following [RFC 430](https://github.com/rust-lang/rfcs/blob/master/text/0430-finalizing-naming-conventions.md)
- Write idiomatic, safe, and efficient Rust code that follows the borrow checker's rules
- Ensure code compiles without warnings (treat warnings as errors in CI)

## Code Structure

### Module Organization

```rust
// lib.rs or main.rs
mod error;    // Custom error types
mod model;    // Domain types
mod service;  // Business logic
mod storage;  // Persistence

// Public API
pub use error::{Error, Result};
pub use model::*;
```

### Project Organization
- Use semantic versioning in `Cargo.toml`
- Include comprehensive metadata: `description`, `license`, `repository`, `keywords`, `categories`
- Use feature flags for optional functionality
- Organize code into modules using `mod.rs` or named files
- Keep `main.rs` or `lib.rs` minimal - move logic to modules
- Split binary and library code (`main.rs` vs `lib.rs`) for testability and reuse

## Patterns to Follow

### Core Patterns
- Use modules (`mod`) and public interfaces (`pub`) to encapsulate logic
- Handle errors properly using `?`, `match`, or `if let`
- Use `serde` for serialization and `thiserror` or `anyhow` for custom errors
- Implement traits to abstract services or external dependencies
- Structure async code using `async/await` and `tokio` or `async-std`
- Prefer enums over flags and states for type safety
- Use builders for complex object creation
- Use `rayon` for data parallelism and CPU-bound tasks
- Use iterators instead of index-based loops as they're often faster and safer
- Use `&str` instead of `String` for function parameters when you don't need ownership
- Prefer borrowing and zero-copy operations to avoid unnecessary allocations

### Ownership, Borrowing, and Lifetimes
- Prefer borrowing (`&T`) over cloning unless ownership transfer is necessary
- Use `&mut T` when you need to modify borrowed data
- Explicitly annotate lifetimes when the compiler cannot infer them
- Use `Rc<T>` for single-threaded reference counting and `Arc<T>` for thread-safe reference counting
- Use `RefCell<T>` for interior mutability in single-threaded contexts and `Mutex<T>` or `RwLock<T>` for multi-threaded contexts

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

### Trait-Based Polymorphism

```rust
trait Processor {
  fn process(&self, data: &str) -> Result<String>;
}

// Generic over trait
fn run<P: Processor>(p: &P, data: &str) -> Result<String> {
  p.process(data)
}

// Multiple trait bounds
fn complex<T>(item: &T) -> String
where
  T: Display + Clone + Debug,
{
  format!("{:?}", item)
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

### Async/Await Pattern

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

## Patterns to Avoid

### Anti-Patterns

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

### Prefer These Alternatives

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

### General Anti-Patterns to Avoid
- Don't use `unwrap()` or `expect()` unless absolutely necessary—prefer proper error handling
- Avoid panics in library code—return `Result` instead
- Don't rely on global mutable state—use dependency injection or thread-safe containers
- Avoid deeply nested logic—refactor with functions or combinators
- Don't ignore warnings—treat them as errors during CI
- Avoid `unsafe` unless required and fully documented
- Don't overuse `clone()`, use borrowing instead of cloning unless ownership transfer is needed
- Avoid premature `collect()`, keep iterators lazy until you actually need the collection
- Avoid unnecessary allocations—prefer borrowing and zero-copy operations

## Error Handling

### Core Principles
- Use `Result<T, E>` for recoverable errors and `panic!` only for unrecoverable errors
- Prefer `?` operator over `unwrap()` or `expect()` for error propagation
- Create custom error types using `thiserror` or implement `std::error::Error`
- Use `Option<T>` for values that may or may not exist
- Provide meaningful error messages and context
- Error types should be meaningful and well-behaved (implement standard traits)
- Validate function arguments and return appropriate errors for invalid input

### Custom Error Types

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
  #[error("IO: {0}")]
  Io(#[from] std::io::Error),
  
  #[error("Parse error: {0}")]
  Parse(#[from] std::num::ParseIntError),
  
  #[error("Not found: {0}")]
  NotFound(String),
  
  #[error("Invalid data (expected {expected:?}, found {found:?})")]
  Invalid { expected: String, found: String },
}

pub type Result<T> = std::result::Result<T, AppError>;

// Never .unwrap() - use ?
fn process() -> Result<String> {
  let data = std::fs::read_to_string("file.txt")?;
  Ok(data.trim().to_string())
}
```

### Using Anyhow for Context

```rust
use anyhow::{Context, Result};

fn process_config() -> Result<Config> {
  let content = std::fs::read_to_string("config.toml")
    .context("Failed to read config file")?;
  
  let config: Config = toml::from_str(&content)
    .context("Failed to parse config")?;
  
  Ok(config)
}
```

## Type Safety

### Newtypes for Domain Safety

```rust
// Newtype for domain safety (zero cost)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct UserId(u64);

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct ProductId(u64);

impl UserId {
  pub fn new(id: u64) -> Self {
    Self(id)
  }
  
  pub fn as_u64(&self) -> u64 {
    self.0
  }
}

// Compiler prevents mixing types
fn get_user(id: UserId) -> User { ... }
fn get_product(id: ProductId) -> Product { ... }

// ❌ get_user(ProductId(123));  // Compile error!
```

### Const Generics

```rust
// Const generics for compile-time validation
fn process<const N: usize>(data: [i32; N]) -> [i32; N] {
  data.map(|x| x * 2)
}

// Usage
let input = [1, 2, 3, 4];
let output = process(input);  // Type-safe, no runtime checks
```

### Phantom Types for State Machines

```rust
use std::marker::PhantomData;

struct Empty;
struct Filled;

struct Builder<State> {
  data: String,
  _marker: PhantomData<State>,
}

impl Builder<Empty> {
  fn new() -> Self {
    Self {
      data: String::new(),
      _marker: PhantomData,
    }
  }
  
  fn set_data(mut self, data: String) -> Builder<Filled> {
    self.data = data;
    Builder {
      data: self.data,
      _marker: PhantomData,
    }
  }
}

impl Builder<Filled> {
  fn build(self) -> String {
    self.data
  }
}
```

## Performance Optimization

### Zero-Cost Abstractions

```rust
// Iterators compile to tight loops (zero cost)
fn sum_evens(nums: &[i32]) -> i32 {
  nums.iter().filter(|&&n| n % 2 == 0).sum()
}

// Equivalent to manual loop but more expressive
fn sum_evens_manual(nums: &[i32]) -> i32 {
  let mut sum = 0;
  for &n in nums {
    if n % 2 == 0 {
      sum += n;
    }
  }
  sum
}
```

### Cow for Conditional Ownership

```rust
use std::borrow::Cow;

fn maybe_clone(s: &str, modify: bool) -> Cow<'_, str> {
  if modify {
    Cow::Owned(s.to_uppercase())
  } else {
    Cow::Borrowed(s)
  }
}

// Only allocates when necessary
let original = "hello";
let borrowed = maybe_clone(original, false);  // No allocation
let owned = maybe_clone(original, true);      // Allocates
```

### SmallVec for Small Collections

```rust
use smallvec::SmallVec;

// Stack-first vector (8 elements on stack, heap if more)
let mut vec: SmallVec<[u32; 8]> = SmallVec::new();
vec.extend(0..4);  // On stack
vec.extend(0..10); // Moves to heap when needed
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

#[inline(never)]
fn large_fn() {
  // Complex logic that shouldn't be inlined
}
```

## API Design Guidelines

### Common Traits Implementation

Eagerly implement common traits where appropriate:
- `Copy`, `Clone`, `Eq`, `PartialEq`, `Ord`, `PartialOrd`, `Hash`, `Debug`, `Display`, `Default`
- Use standard conversion traits: `From`, `AsRef`, `AsMut`
- Collections should implement `FromIterator` and `Extend`
- Note: `Send` and `Sync` are auto-implemented by the compiler when safe; avoid manual implementation unless using `unsafe` code

### Type Safety and Predictability
- Use newtypes to provide static distinctions
- Arguments should convey meaning through types; prefer specific types over generic `bool` parameters
- Use `Option<T>` appropriately for truly optional values
- Functions with a clear receiver should be methods
- Only smart pointers should implement `Deref` and `DerefMut`

### Future Proofing
- Use sealed traits to protect against downstream implementations
- Structs should have private fields
- Functions should validate their arguments
- All public types must implement `Debug`

## Unsafe Code

### When Required

```rust
unsafe fn from_raw_parts(ptr: *const u8, len: usize) -> &'static [u8] {
  // SAFETY: Caller guarantees ptr is valid for len bytes
  // and the data lives for 'static lifetime
  std::slice::from_raw_parts(ptr, len)
}
```

### Minimize Surface Area

```rust
// Wrap unsafe in safe API
pub fn safe_wrapper(data: &[u8]) -> &[u8] {
  unsafe {
    // SAFETY: data is valid for the lifetime of the borrow
    from_raw_parts(data.as_ptr(), data.len())
  }
}
```

### Safety Documentation
- Document all safety invariants with `// SAFETY:` comments
- Explain why unsafe code is necessary
- Verify with `cargo miri test` when possible
- Minimize unsafe surface area - wrap in safe abstractions

## Code Style and Formatting

- Follow the Rust Style Guide and use `rustfmt` for automatic formatting
- Keep lines under 100 characters when possible
- Use 2-space indentation (configured in `rustfmt.toml`)
- Place function and struct documentation immediately before the item using `///`
- Use `cargo clippy` to catch common mistakes and enforce best practices
- Configure strict Clippy lints in `Cargo.toml`:

```toml
[lints.clippy]
all = "deny"
pedantic = "warn"
nursery = "warn"
cargo = "warn"
```

## Testing and Documentation

### Unit Tests

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
  
  #[test]
  fn test_result() -> Result<()> {
    let result = process("input")?;
    assert_eq!(result, "expected");
    Ok(())
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
///
/// # Errors
/// Returns error if input is empty
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
  
  #[test]
  fn test_sorted_vec(mut v in prop::collection::vec(0..100i32, 0..100)) {
    v.sort();
    for i in 1..v.len() {
      prop_assert!(v[i-1] <= v[i]);
    }
  }
}
```

### Integration Tests
- Write integration tests in `tests/` directory with descriptive filenames
- Test public API behavior from external perspective
- Use separate files for different test suites

### Documentation Requirements
- Write comprehensive unit tests using `#[cfg(test)]` modules and `#[test]` annotations
- Use test modules alongside the code they test (`mod tests { ... }`)
- Write clear and concise comments for each function, struct, enum, and complex logic
- Ensure functions have descriptive names and include comprehensive documentation
- Document all public APIs with rustdoc (`///` comments) following the [API Guidelines](https://rust-lang.github.io/api-guidelines/)
- Use `#[doc(hidden)]` to hide implementation details from public documentation
- Document error conditions, panic scenarios, and safety considerations
- Examples should use `?` operator, not `unwrap()` or deprecated `try!` macro

## Toolchain and Workflow

### Essential Commands

```bash
# Lint + format + test (full quality check)
cargo fmt && cargo clippy --all-targets -- -D warnings && cargo test

# Safety audit
cargo miri test && cargo audit

# Performance
cargo bench && cargo flamegraph

# Dependencies
cargo tree && cargo machete && cargo outdated
```

### Release Profile Configuration

```toml
[profile.release]
lto = true              # Link-time optimization
codegen-units = 1       # Better optimization
panic = "abort"         # Smaller binary
strip = true            # Remove debug symbols

[profile.bench]
inherits = "release"
```

### Common Crates

#### Essential
- `serde` - Serialization/deserialization
- `tokio` - Async runtime
- `thiserror` - Error type derivation
- `anyhow` - Error context and propagation

#### Performance
- `rayon` - Data parallelism
- `crossbeam` - Concurrent data structures
- `smallvec` - Stack-first vectors
- `criterion` - Benchmarking

#### Utilities
- `clap` - CLI parsing
- `env_logger` - Logging
- `tracing` - Structured logging/tracing
- `reqwest` - HTTP client
- `sqlx` - Async SQL

## Quick Wins

### Format and Lint
```bash
cargo fmt && cargo clippy --fix
```

### Update Dependencies
```bash
cargo update && cargo audit
```

### Benchmark with Baseline
```bash
cargo bench -- --save-baseline main
# Make changes
cargo bench -- --baseline main
```

### Performance Profiling
```bash
cargo build --release
perf record ./target/release/myapp
perf report
```

## Quality Checklist

Before publishing or reviewing Rust code, ensure:

### Core Requirements
- [ ] **Naming**: Follows RFC 430 naming conventions
- [ ] **Traits**: Implements `Debug`, `Clone`, `PartialEq` where appropriate
- [ ] **Error Handling**: Uses `Result<T, E>` and provides meaningful error types
- [ ] **Documentation**: All public items have rustdoc comments with examples
- [ ] **Testing**: Comprehensive test coverage including edge cases

### Safety and Quality
- [ ] **Safety**: No unnecessary `unsafe` code, proper error handling
- [ ] **Performance**: Efficient use of iterators, minimal allocations
- [ ] **API Design**: Functions are predictable, flexible, and type-safe
- [ ] **Future Proofing**: Private fields in structs, sealed traits where appropriate
- [ ] **Tooling**: Code passes `cargo fmt`, `cargo clippy -- -D warnings`, and `cargo test`

### Performance Checklist
- [ ] Use iterators over manual loops
- [ ] Prefer `&str` over `String` for function parameters
- [ ] Minimize `clone()` calls - prefer borrowing
- [ ] Use `Cow<'_, T>` for conditional ownership
- [ ] Apply `#[inline]` only after profiling
- [ ] Verify zero-cost abstractions with `cargo asm` or flamegraphs

### Documentation Checklist
- [ ] All public functions have `///` documentation
- [ ] Examples compile and run correctly (test with `cargo test --doc`)
- [ ] Error conditions documented
- [ ] Panic scenarios documented (if any)
- [ ] Safety invariants documented for `unsafe` code
