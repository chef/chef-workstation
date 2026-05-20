package commands

import (
	"fmt"
	"os"
	"strings"
	"time"
)

var cliIO = &CLIIO{}

type StructuredField struct {
	Key   string
	Value string
}

type CLIIO struct {
	EnableVerbose bool
}

func (c *CLIIO) msg(format string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, newlineify(format), args...)
}

func (c *CLIIO) out(format string, args ...interface{}) {
	fmt.Fprintf(os.Stdout, newlineify(format), args...)
}

func (c *CLIIO) verbose(format string, args ...interface{}) {
	if c.EnableVerbose {
		c.msg(newlineify(format), args...)
	}
}

func (c *CLIIO) structuredVerbose(op string, status string, elapsed time.Duration, fields ...StructuredField) {
	if c.EnableVerbose {
		c.msg(structuredLogLine(op, status, elapsed, fields...))
	}
}

func structuredLogLine(op string, status string, elapsed time.Duration, fields ...StructuredField) string {
	parts := []string{
		fmt.Sprintf("op=%s", op),
		fmt.Sprintf("status=%s", status),
		fmt.Sprintf("elapsed_ms=%d", elapsed.Milliseconds()),
	}

	for _, field := range fields {
		parts = append(parts, fmt.Sprintf("%s=%s", field.Key, field.Value))
	}

	return strings.Join(parts, " ")
}

func newlineify(s string) string {
	if !strings.HasSuffix(s, "\n") {
		return fmt.Sprintf("%s\n", s)
	}
	return s
}
