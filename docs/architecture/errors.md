## Error Handling


### Summary

Errors in the form of exceptions can occur at any phase of chef-run's execution.
The broad categories of these errors are:

Remote:
* connection failure
* authentication failure (train error)
* execution error
* upload error
* chef-client error (related to cookbook content)

Local:
* setup/initialization failures
* validation error
* usage error
* interrupts
* third party library errors

Any of these errors can be raised on the main UI thread, or in a background thread when using multi-target.


### Requirements

UX:
* Never present a stack-trace to the operator
* For known/expected errors, always provide a path forward in the error message text.
* For unknown/unexpected errors, provide what information we can and guide the operator
  towards support email with supporting logs and information.
* More specific is better.  "Connection Failed" vs "The host name %1 could not be resolved. "
* Errors in background jobs (multi-target) must not prevent other jobs from completing.
* Errors in background jobs must provide an update to the 'spinner' for that job indicating failure.

Engineering:
* Telemetry around all errors must be captured with context (eg, what action was being performed)
  * identifying or sensitive information must be removed before sending
    * err in favor of not sending any detail if there's any question of whether an exception
      could contain PII
* Stack traces must be logged for all non-validation errors, with sufficient context to identify the task being
  performed.

### Current State

#### Top-level/Common
At a high level, all unhandled and explicitly raised exceptions bubble up to the
top-level CLI#run handler, which uses CLI#handle_run_error to process the error
and determine the appropriate exit code:
  - no errors (0)
  - a completely unexpected error slipped by all checks (32)
  - an error occurred in the error handler (64)
  - (n/a in chef-run) a locally run external command has failed (external command exit code is returned)
  - task failed to run to completion for any other reason (1)

"expected" errors - anything that exits RC 1 - are WrappedErrors (see Single Target below).
These are rendered by UI::ErrorPrinter.show_error. See "Rendering" below for more information.

"unexpected" errors - anything other than a 0 exit code - are rendered without normal decoration
via ErrorPrinter.dump_unexpected_error.

*all* exceptions are handled this way, because we have strict UX requirements that we never show a stack
trace to the operator.

#### Single-target
When an error is raised in anything done by CLI#perform_run (invoked from CLI#run above0  (terminating in CLI#perform_run), we invoke
CLI#handle_perform_error, which:
- captures a telemetry record with the error message ID if it exists, otherwise the class name.
  - We do not currently capture the error message out of concerns for PII.
- writes the the backtrace for the exception
- wraps the exception (WrappedException) vi StandardErrorResolver.wrap_exception
  - wrap_exception also performs a mapping of common standard errors to chef-run
    errors so that we can render better help text for those errors.
    In this case the wrapped exception will not be the original, but the mapped
    ChefRun::Error class instance.
- raise the wrapper, which is caught by the CLI#run handler for user-facing formatting. The intent
  here was to separate out the user-facing aspect from the internal error management.

#### Multi-target

* a Terminal::Job instance is created for each target host. It runs the block
  provided - in this case, performing the chef install and executing the cookbook.
* When an exception occurs:
  * the job status (spinner) is updated with the  exception error message
  * it is rescued and assigned to an exposed instance var
  * the job is terminated
* After all jobs are completed (Terminal.render_parallel_jobs),
  * CLI.run_multi_target iterates the job instances and gathers up failures
    * failures in this context usually have additional information available, such as
      the target host and the action being performed.
  * raises a new ChefRun::MultiJobFailure that contains the executed jobs
  * handling from this point forward follows the single-target path.

#### Raises
Internally, all exceptions originating from within chef-run that are not captured
inline are descendants of ChefRun::Error, which requires an error ID
accepts optional arguments that are necessary for rendering the error.

ChefRun::Error exposes attributes to control how the error is rendered. See "Rendering" below.

By convention, class-specific errors are defined inline with the same class that raises them.

#### Inline Handling
In several places we perform inline handling in order to map the error to a chef-run
error, so that we get proper rendering of the error.

An example of this can be found in `TargetHost#connect!` - it captures a Train::UserError and
raises a ConnectionFailure with error code and message based on the details it extracted from the
UserError.

We similarly parse out specific cookbook-related errors during a remote run failure and
raise an appropriate ChefRun error that includes likely cause/remediation for the erorr.

#### Formatting and Rendering
This is handled by UI::ErrorPrinter.

The primary interface is `ErrorPrinter.show_error` which accepts a WrappedException and renders it to the terminal
via `ErrorPrinter#format_error`.

These look at the attributes of the exception (if it's ChefRun::Error-derived) to determine how to format it.
It renders the error in parts:
- header: the error ID, in bold
- body - the customer-facing text of the error
  - Note that this contains additional handling to do formatting specific to
   certain error types (chef-run, train, and anything else).  This is an additional
   place that we do error mapping, in addition to StandardErrorResolver mentioned above.
  - chef-run errors
    - have their customer-facing text defined in i18n under the key "errors.ERROR_ID"
  - train error
    - these get manually mapped to CHEFTRN001/2 (depending if a TargetHost is available)
    - the error message is presented as-is to the operator
  - other errors
    - these get rendered as CHEFINT001
    - the error message is presented as-is to the operator
- footer - the trailing bits of the error
  - unless suppressed by ChefJob::Error options, we will render a footer using the
    following i18n keys:
    - `error.footer.both` - footer gives location of log file and stack trace file
      - typically used for errors we don't expect to see
      - maps to ChefRun::Error#show_stack == true && show_log == true
    - `error.footer.log_only` - footer gives location of log file
      - maps to ChefRun::Error#show_stack == false && show_log == true
    - `error.footer.stack_only` - footer gives location of stack trace capture
      - maps to ChefRun::Error#show_stack == true && show_log == false
    - `error.footer.neither` - generic message that just says to contact beta@chef.io if you can't fix the error.
      - used for errors when the cause and remediation are clear, for example
        bad option arguments to the CLI.
      - maps to ChefRun::Error#show_stack == false && show_log == false

#### One-off Formatting

The Startup class runs outside of the main error handling, and does its own formatting
of the errors it expects to see.


