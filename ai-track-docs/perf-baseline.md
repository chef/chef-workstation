# Performance Baseline

## Module

`components/chef-automate-collect/commands/metadata_collectors.go`

## Function

`gitRemoteNameFromEnv`

## Command

Run from the repository root:

```sh
cd components/chef-automate-collect
go test ./commands -run 'TestGitRemoteNameFromEnv|TestEnvironmentVariableConstantsStable' -bench BenchmarkGitRemoteNameFromEnv -benchmem -count=5
```

## Environment

- `goos: darwin`
- `goarch: arm64`
- `cpu: Apple M4 Pro`

## Baseline Results

Five benchmark runs were recorded for each sub-case.

| Case | Observed range | Allocations |
|------|----------------|-------------|
| `unset` | `1.692 ns/op` to `1.732 ns/op` | `0 B/op`, `0 allocs/op` |
| `whitespace` | `13.31 ns/op` to `13.75 ns/op` | `16 B/op`, `1 allocs/op` |
| `trimmed_value` | `13.30 ns/op` to `13.62 ns/op` | `16 B/op`, `1 allocs/op` |

## Variance Notes

- The `unset` path is effectively allocation-free and stayed within roughly 2.4% across five runs.
- The whitespace and trimmed-value paths stayed within roughly 3.3% and 2.4% respectively across five runs.
- This is a measurement baseline only; no optimization target is implied by these numbers.