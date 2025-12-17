---
description: "Go idiomatic practices and community standards"
applyTo: "**/*.go,**/go.mod,**/go.sum"
---

# Go Best Practices

Based on [Effective Go](https://go.dev/doc/effective_go), [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments), [Google's Go Style Guide](https://google.github.io/styleguide/go/).

## Core Principles

- Simple, clear, idiomatic code
- Happy path left-aligned (minimize nesting)
- Return early to reduce nesting
- Make zero value useful
- Standard library > custom implementations
- Document exported symbols

## Naming

**Packages:**

- Lowercase, single-word, no underscores
- Avoid `util`, `common`, `base`
- Singular, not plural
- **ONE** `package` declaration per file

**Variables/Functions:**

- mixedCaps or MixedCaps (camelCase)
- Exported: Capital letter
- Unexported: Lowercase
- Avoid stuttering: `http.Server` not `http.HTTPServer`

**Interfaces:**

- Single-method: `-er` suffix (`Reader`, `Writer`)
- Name after method (`Read` → `Reader`)
- Keep small and focused

**Constants:**

- MixedCaps (exported) or mixedCaps (unexported)
- Group related constants

```go
package api

const (
  StatusActive  = "active"
  StatusPending = "pending"
)

type Reader interface {
  Read(p []byte) (n int, err error)
}
```

## Code Style

**Format:** `gofmt`, `goimports`

**Early Return:**

```go
// ✅ Good
func process(data string) error {
  if data == "" {
    return errors.New("empty data")
  }
  // Happy path
  return doWork(data)
}

// ❌ Bad
func process(data string) error {
  if data != "" {
    return doWork(data)
  } else {
    return errors.New("empty data")
  }
}
```

## Error Handling

```go
// Define custom errors
var (
  ErrNotFound = errors.New("not found")
  ErrInvalid  = errors.New("invalid input")
)

// Wrap errors
func loadConfig(path string) (*Config, error) {
  data, err := os.ReadFile(path)
  if err != nil {
    return nil, fmt.Errorf("load config: %w", err)
  }
  // ...
  return config, nil
}

// Check specific errors
if errors.Is(err, ErrNotFound) {
  // Handle not found
}

// Check error type
var perr *os.PathError
if errors.As(err, &perr) {
  // Handle path error
}
```

## Concurrency

**Goroutines:**

```go
// Launch goroutines
go func() {
  // Work
}()

// WaitGroup for coordination
var wg sync.WaitGroup
for i := 0; i < 10; i++ {
  wg.Add(1)
  go func(id int) {
    defer wg.Done()
    process(id)
  }(i)
}
wg.Wait()
```

**Channels:**

```go
// Buffered channel
ch := make(chan int, 10)

// Send/receive
ch <- 42
val := <-ch

// Close channel
close(ch)

// Range over channel
for msg := range ch {
  process(msg)
}
```

**Context:**

```go
func process(ctx context.Context, data string) error {
  // Check cancellation
  select {
  case <-ctx.Done():
    return ctx.Err()
  default:
  }

  // Pass context to children
  return doWork(ctx, data)
}

// Create with timeout
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
```

**sync.Once:**

```go
var (
  instance *Service
  once     sync.Once
)

func GetService() *Service {
  once.Do(func() {
    instance = &Service{}
  })
  return instance
}
```

## Structs

**Zero Value:**

```go
type Config struct {
  Host    string
  Port    int // Zero value: 0
  Enabled bool // Zero value: false
}

// Zero value is ready to use
var cfg Config // Host="", Port=0, Enabled=false
```

**Constructor:**

```go
type Server struct {
  addr    string
  timeout time.Duration
}

func NewServer(addr string) *Server {
  return &Server{
    addr:    addr,
    timeout: 30 * time.Second,
  }
}
```

**Embedding:**

```go
type Base struct {
  ID   string
  Name string
}

type User struct {
  Base    // Embedded
  Email string
}

u := User{
  Base:  Base{ID: "1", Name: "Alice"},
  Email: "alice@example.com",
}
```

## Interfaces

```go
// Define small interfaces
type Reader interface {
  Read(p []byte) (n int, err error)
}

type Writer interface {
  Write(p []byte) (n int, err error)
}

// Compose interfaces
type ReadWriter interface {
  Reader
  Writer
}

// Accept interfaces, return structs
func Process(r Reader) (*Result, error) {
  // ...
  return &Result{}, nil
}
```

## Type Safety

**Type Switches:**

```go
func handle(v interface{}) {
  switch v := v.(type) {
  case int:
    fmt.Println("int:", v)
  case string:
    fmt.Println("string:", v)
  default:
    fmt.Println("unknown:", v)
  }
}
```

**Type Assertions:**

```go
if str, ok := v.(string); ok {
  process(str)
}
```

## Testing

```go
func TestProcess(t *testing.T) {
  tests := []struct {
    name    string
    input   string
    want    string
    wantErr bool
  }{
    {"valid", "test", "TEST", false},
    {"empty", "", "", true},
  }

  for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
      got, err := Process(tt.input)
      if (err != nil) != tt.wantErr {
        t.Errorf("Process() error = %v, wantErr %v", err, tt.wantErr)
        return
      }
      if got != tt.want {
        t.Errorf("Process() = %v, want %v", got, tt.want)
      }
    })
  }
}

// Benchmarks
func BenchmarkProcess(b *testing.B) {
  for i := 0; i < b.N; i++ {
    Process("test")
  }
}

// Helpers
func assertEqual(t *testing.T, got, want interface{}) {
  t.Helper()
  if got != want {
    t.Errorf("got %v, want %v", got, want)
  }
}
```

## Performance

**String Builder:**

```go
// ✅ Efficient
var b strings.Builder
for _, s := range strs {
  b.WriteString(s)
}
result := b.String()

// ❌ Inefficient
var result string
for _, s := range strs {
  result += s
}
```

**Preallocate Slices:**

```go
// ✅ Preallocate
items := make([]Item, 0, len(data))

// ❌ Dynamic growth
var items []Item
```

**Sync.Pool:**

```go
var bufPool = sync.Pool{
  New: func() interface{} {
    return new(bytes.Buffer)
  },
}

func process() {
  buf := bufPool.Get().(*bytes.Buffer)
  defer bufPool.Put(buf)
  buf.Reset()
  // Use buffer
}
```

## Common Patterns

**Functional Options:**

```go
type Server struct {
  addr    string
  timeout time.Duration
}

type Option func(*Server)

func WithTimeout(d time.Duration) Option {
  return func(s *Server) {
    s.timeout = d
  }
}

func NewServer(addr string, opts ...Option) *Server {
  s := &Server{
    addr:    addr,
    timeout: 30 * time.Second,
  }
  for _, opt := range opts {
    opt(s)
  }
  return s
}

// Usage
srv := NewServer(":8080", WithTimeout(60*time.Second))
```

**Worker Pool:**

```go
func processJobs(jobs <-chan Job, results chan<- Result) {
  const numWorkers = 5
  var wg sync.WaitGroup

  for i := 0; i < numWorkers; i++ {
    wg.Add(1)
    go func() {
      defer wg.Done()
      for job := range jobs {
        results <- process(job)
      }
    }()
  }

  wg.Wait()
  close(results)
}
```

## Security

**Input Validation:**

```go
func sanitize(input string) (string, error) {
  if len(input) == 0 {
    return "", errors.New("empty input")
  }
  if len(input) > 1000 {
    return "", errors.New("input too long")
  }
  return strings.TrimSpace(input), nil
}
```

**SQL Injection Prevention:**

```go
// ✅ Use parameterized queries
stmt, err := db.Prepare("SELECT * FROM users WHERE id = ?")
defer stmt.Close()
rows, err := stmt.Query(userID)

// ❌ Never concatenate
query := "SELECT * FROM users WHERE id = " + userID // UNSAFE
```

## Toolchain

```bash
# Format
go fmt ./...
goimports -w .

# Lint
golangci-lint run

# Test
go test ./...
go test -race ./...
go test -cover ./...

# Bench
go test -bench=. -benchmem

# Vet
go vet ./...

# Build
go build -o app ./cmd/app
```

## Project Structure

```
myapp/
├── cmd/
│   └── myapp/
│       └── main.go
├── internal/
│   ├── api/
│   ├── service/
│   └── storage/
├── pkg/
│   └── shared/
├── go.mod
└── go.sum
```

**Rules:**

- `cmd/`: Application entrypoints
- `internal/`: Private code (not importable)
- `pkg/`: Public libraries
- Keep `main.go` minimal

## Checklist

- [ ] `gofmt` applied
- [ ] `goimports` for imports
- [ ] No compiler warnings
- [ ] Tests pass (`go test ./...`)
- [ ] Race detector clean (`go test -race`)
- [ ] `go vet` clean
- [ ] Exported symbols documented
- [ ] Error handling (wrap with `%w`)
- [ ] Context propagation
- [ ] ONE `package` declaration per file
