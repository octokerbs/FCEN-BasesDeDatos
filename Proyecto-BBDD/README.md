# Average Go project structure
```
myapp/
├── cmd/
├── pkg/
├── internal/
├── api/
├── configs/
├── deployments/
├── scripts/
├── build/
├── test/
├── go.mod
├── go.sum
└── README.md
```

## Key directories

- `cmd` Each subfolder here is an entry point (binary). Example:
```
cmd/
├── myapp/
│   └── main.go
└── worker/
    └── main.go
```

- `pkg/`
Public libraries your app exports. Reusable code others could import. Example:
```
pkg/
├── logger/
├── metrics/
└── version/
```

- `internal/`
Private application code (Go enforces this). Anything here cannot be imported outside your repo. Example: 
```
internal/
├── service/
├── repository/
└── http/
```

- `api/`
Protobuf/gRPC/OpenAPI definitions. Sometimes just JSON schema. Example: 
```
api/
├── v1/
│   ├── myapp.proto
│   └── swagger.yaml
```

- `configs/`
Config files (YAML, JSON, TOML). Defaults, examples, templates.

- `deployments/`
Docker, Kubernetes manifests, Helm charts.

- `scripts/`
Helper scripts (bash, make, etc.) for build/test/deploy automation.

- `build/`
Packaging stuff (Dockerfile, CI/CD configs, systemd units).

- `test/`
Integration tests and test data (not just _test.go unit tests).

# Naming conventions

## Package naming conventions
- All lowercase, short, concise names.
Example: net/http, fmt, io, math.
Avoid underscores, mixedCaps, or long names.

- No repetition of the project/repo name.
If your repo is github.com/wizard/calc, don’t make the package calc/calc. Just use calc.

- Name matches the directory.
The folder math contains the package math.

- Singular, not plural (usually).
Prefer user, not users. Exceptions exist, but Go favors singular.

- Avoid generic names.
Don’t name a package util, common, or helpers. Those become dumping grounds. Instead, choose something domain-specific.

- Exported identifiers give context, package names should not.
You don’t write user.UserStruct → just user.User. Package name is part of the identifier.
Example: bytes.Buffer instead of bytes.BytesBuffer.

## Directory Naming Conventions
- Directory name = package name.
If the directory is auth, the files inside should declare package auth.

- One package per directory.
Go enforces this. You can’t mix multiple packages in a single directory (except *_test files which can use package xxx_test).

- Internal packages.
If you want code hidden from external consumers, put it under an internal/ directory.
Example: project/internal/config.

- Cmd directories for binaries.
If your project has executables, put them under cmd/<appname>/.
Example: cmd/server/main.go → produces a server binary.

- Keep directory hierarchy flat.
Avoid deep nesting like pkg/foo/bar/baz/. Go favors fewer levels.

- Third-party conventions.
Some projects use pkg/ for public packages and internal/ for private ones, but this is more convention than requirement.

## File Naming

- Lowercase, underscores only when needed.
Example: http_server.go, config.go.
No camelCase, no PascalCase, no dashes (- are not allowed).

- If a file has OS-specific code, suffix it with _linux.go, _windows.go, etc.

- If it’s for tests: xxx_test.go.

## Example
```
github.com/wizard/calc/
    cmd/
        cli/
            main.go        → package main
    internal/
        parser/
            parser.go      → package parser
    math/
        sum.go            → package math
    go.mod

```

# Run the code

- Run the entire package
```bash
go run <package-path> 
```

- Run all the tests
```bash
go test ./...

```

- Run all the tests in package
```bash
go test <package-path>
```

- Compile package
```bash
go build <package-path>
```