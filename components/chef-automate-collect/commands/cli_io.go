package commands

import (
	"fmt"
	"os"
	"strconv"
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

func structuredLoggingEnabled(lookupEnv func(string) (string, bool)) bool {
	value, isSet := lookupEnv(StructuredLogsEnvVar)
	if !isSet {
		return true
	}

	return strings.TrimSpace(value) != "false"
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
	if c.EnableVerbose && structuredLoggingEnabled(os.LookupEnv) {
		c.msg(structuredLogLine(op, status, elapsed, fields...))
	}
}

func structuredLogLine(op string, status string, elapsed time.Duration, fields ...StructuredField) string {
	buf := strings.Builder{}
	buf.Grow(32 + len(op) + len(status) + len(fields)*16)

	buf.WriteString("op=")
	buf.WriteString(op)
	buf.WriteString(" status=")
	buf.WriteString(status)
	buf.WriteString(" elapsed_ms=")
	buf.WriteString(strconv.FormatInt(elapsed.Milliseconds(), 10))

	for _, field := range fields {
		buf.WriteByte(' ')
		buf.WriteString(field.Key)
		buf.WriteByte('=')
		buf.WriteString(field.Value)
	}

	return buf.String()
}

func newlineify(s string) string {
	if !strings.HasSuffix(s, "\n") {
		return s + "\n"
	}
	return s
}
