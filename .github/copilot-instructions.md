# GitHub Copilot Instructions for Chef Workstation

This document provides comprehensive instructions for GitHub Copilot when working with the Chef Workstation repository.

## Repository Overview

Chef Workstation is a comprehensive package that installs everything needed to get started with Chef products on Windows, Mac, and Linux. It includes Chef Infra Client, Chef InSpec, Chef Habitat, Chef Command Line Tool, Test Kitchen, Cookstyle, and various plugins.

## Repository Structure

The Chef Workstation repository follows this structure:

```
chef-workstation/
├── .expeditor/                    # Build and release automation
├── .github/                       # GitHub workflows and templates
│   ├── CODEOWNERS                # Code ownership definitions
│   ├── ISSUE_TEMPLATE/           # Issue templates
│   ├── dependabot.yml           # Dependabot configuration
│   └── workflows/               # CI/CD workflows (sonarqube.yml, unit.yml)
├── CHANGELOG.md                  # Version history and changes
├── CODE_OF_CONDUCT.md           # Community guidelines
├── CONTRIBUTING.md              # Contribution guidelines
├── README.md                    # Project documentation
├── RELEASE_PROCESS.md           # Release process documentation
├── Gemfile                      # Ruby dependencies
├── Rakefile                     # Build tasks
├── VERSION                      # Current version
├── components/                  # Core components
│   ├── chef-automate-collect/   # Chef Automate data collection tool (Go)
│   ├── gems/                    # Ruby gems and dependencies
│   ├── main-chef-wrapper/       # Main chef wrapper (Go)
│   ├── packaging/               # Packaging components (Chocolatey)
│   └── rehash/                  # Rehash utilities
├── coverage/                    # Code coverage reports
├── dev-docs/                    # Developer documentation
│   ├── architecture/            # Architecture diagrams and docs
│   ├── clibuddy/               # CLI buddy configurations
│   └── img/                    # Documentation images
├── docs-chef-io/               # Chef.io documentation site
├── habitat/                     # Chef Habitat packaging
├── omnibus/                     # Omnibus packaging configuration
│   ├── config/                  # Omnibus configuration
│   ├── cookbooks/              # Build cookbooks
│   ├── files/                  # Build files and scripts
│   ├── package-scripts/        # Package installation scripts
│   ├── resources/              # Omnibus resources
│   └── verification/           # Package verification tests
├── test/                       # Test suites
│   └── integration/            # Integration tests
├── sonar-project.properties    # SonarQube configuration
├── cspell.json                # Spell check configuration
├── dobi.yaml                  # Docker build configuration
└── Dockerfile                 # Container build definition
```

## Development Workflow

### 1. Task Implementation with Jira Integration

When a Jira ID is provided:

1. **Fetch Jira Details**: Use the `atlassian-mcp-server` MCP server to fetch the Jira issue details
2. **Read and Analyze**: Carefully read the story description, acceptance criteria, and requirements
3. **Plan Implementation**: Break down the task into actionable steps
4. **Implement**: Follow the implementation guidelines below

### 2. Implementation Guidelines

- **Code Quality**: Follow existing code patterns and conventions
- **Testing**: Always create comprehensive unit tests for your implementation
- **Coverage**: Maintain code coverage above 80% for the repository
- **Documentation**: Update relevant documentation when making changes
- **Dependencies**: Use appropriate dependency management (Gemfile for Ruby, go.mod for Go)

### 3. Testing Requirements

**Comprehensive Testing Strategy:**
- Write unit tests for all new functionality
- Ensure integration tests pass
- Maintain overall repository coverage > 80% (this is a hard requirement)
- Run existing test suites to ensure no regressions
- Test both positive and negative scenarios
- Create mock objects for external dependencies
- Use table-driven test patterns where appropriate

**Testing Framework Usage:**
- Ruby: RSpec, Minitest (~> 5.16)
- Go: Built-in testing package with cross-platform considerations
- Integration: Test Kitchen with multiple drivers

**Test Structure Guidelines:**
```ruby
# Ruby test example
describe "ClassName" do
  context "when condition" do
    it "should behave correctly" do
      # Setup
      # Execute
      # Assert
    end
  end
  
  context "when error condition" do
    it "should handle errors gracefully" do
      # Test error scenarios
    end
  end
end
```

```go
// Go test example
func TestServiceMethod(t *testing.T) {
    tests := []struct {
        name     string
        input    interface{}
        expected interface{}
        wantErr  bool
    }{
        // Test cases here
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test implementation
        })
    }
}
```

**Coverage Verification:**
- Generate and verify coverage reports after running tests
- Ensure all new code has appropriate test coverage
- Test edge cases and error conditions thoroughly
- Verify tests are independent and can run in any order

### 4. Pull Request Creation Process

When prompted to create a PR, follow this comprehensive workflow:

1. **Branch Creation**: Use the Jira ID as the branch name (e.g., `PROJ-123`)
2. **Authentication**: Use GH CLI for all Git operations (no profile-based authentication)
3. **Git Operations**:
   ```bash
   # Create and checkout new branch (use Jira ID)
   git checkout -b <JIRA_ID>
   
   # Stage and commit changes with meaningful messages
   git add .
   git commit -m "<JIRA_ID>: Brief description of changes"
   
   # Push to remote
   git push origin <JIRA_ID>
   
   # Create PR using GH CLI with required labels
   gh pr create --title "<JIRA_ID>: Brief description" --label "runtest:all:stable" --body "$(cat <<EOF
   <h2>Summary</h2>
   <p>Detailed description of changes made</p>
   
   <h2>Jira Ticket</h2>
   <p><a href="https://your-jira-instance.com/browse/{JIRA-ID}">{JIRA-ID}</a></p>
   
   <h2>Changes Made</h2>
   <ul>
   <li>Change 1</li>
   <li>Change 2</li>
   </ul>
   
   <h2>Testing</h2>
   <p>All tests pass with >80% coverage</p>
   
   <h2>Files Modified</h2>
   <ul>
   <li>File 1</li>
   <li>File 2</li>
   </ul>
   EOF
   )"
   ```
4. **PR Description Requirements**:
   - HTML-formatted summary of changes
   - Link to Jira ticket with proper formatting
   - Comprehensive list of changes made
   - Testing performed and coverage results
   - List of all files modified
   - Screenshots/examples if applicable
5. **Label Management**: Add appropriate labels such as "Type: Enhancement" for new features or "Aspect: Documentation" for documentation changes

### 5. Step-by-Step Execution Protocol

**All tasks must be executed in a prompt-based manner:**

1. **After each major step**: Provide a summary of what was completed
2. **Before next step**: Clearly state what the next step will be
3. **Ask for confirmation**: "Do you want me to continue with the next step?"
4. **List remaining steps**: Show what steps are still left to complete
5. **Wait for approval**: Do not proceed until user confirms

This ensures transparency and allows for course correction at any point in the development process.

### 6. Comprehensive Workflow Process

Follow this complete workflow when implementing any task:

#### Phase 1: Initial Setup & Analysis
1. **Jira Analysis** (if Jira ID provided)
   - Use atlassian-mcp-server to fetch Jira issue details
   - Read and analyze the story requirements thoroughly
   - Extract requirements from the story description
   - Identify acceptance criteria and affected components

2. **Repository Analysis**
   - Review existing code patterns and conventions
   - Identify dependencies and related files
   - Check for existing tests and coverage
   - Identify which files can be safely modified

3. **Implementation Planning**
   - Break down task into specific actionable steps
   - Identify files to be created/modified
   - Plan test coverage strategy (must achieve >80%)
   - Plan implementation approach

**Prompt**: "Phase 1 complete. Analysis shows [detailed summary]. Ready to proceed with Phase 2: Implementation? Remaining steps: Implementation → Testing → PR Creation"

#### Phase 2: Implementation Phase
4. **Code Implementation**
   - Follow existing code patterns and conventions
   - Implement required functionality step by step
   - Ensure compatibility with existing codebase
   - Add proper error handling and logging
   - Use appropriate dependency management

5. **Documentation Updates**
   - Update relevant documentation files
   - Add comprehensive inline code comments
   - Update README if functionality changes
   - Document API changes if applicable

**Prompt**: "Phase 2 complete. Implementation finished with [detailed summary of changes]. Ready to proceed with Phase 3: Testing? Remaining steps: Testing → PR Creation"

#### Phase 3: Testing Phase
6. **Unit Test Creation**
   - Create comprehensive unit tests in appropriate test files
   - Ensure test coverage > 80% for all modified code
   - Test both success and error scenarios
   - Use mock objects for external dependencies
   - Follow table-driven test patterns where appropriate

7. **Test Execution & Validation**
   - Run existing test suites to ensure no regressions
   - Verify all new tests pass
   - Generate and verify coverage reports
   - Test edge cases and error conditions
   - Ensure tests are independent and can run in any order

**Prompt**: "Phase 3 complete. Testing shows [coverage percentage and results summary]. All tests pass with >80% coverage. Ready to proceed with Phase 4: PR Creation? Remaining step: PR Creation"

#### Phase 4: Pull Request Creation
8. **Git Operations**
   - Create branch using Jira ID as branch name (e.g., `PROJ-123`)
   - Stage and commit changes with meaningful commit messages
   - Push changes to remote repository
   - Follow proper commit message format

9. **PR Creation & Documentation**
   - Create pull request using GH CLI
   - Include HTML-formatted PR description with:
     - Summary of changes made
     - Link to Jira ticket
     - List of files modified
     - Testing performed and coverage results
     - Screenshots/examples if applicable
   - Add required labels appropriate to the change type (e.g., "Type: Enhancement", "Aspect: Documentation")

**Prompt**: "Phase 4 complete. PR created successfully at [PR URL]. All implementation steps finished. Summary: [complete summary of all work done, files modified, test coverage achieved]. Would you like to perform any additional tasks?"

### 6. Prompt-Based Interaction

**All tasks must be executed in a prompt-based manner:**

1. **After each major step**: Provide a summary of what was completed
2. **Before next step**: Clearly state what the next step will be  
3. **Ask for confirmation**: "Do you want me to continue with the next step?"
4. **List remaining steps**: Show what steps are still left to complete
5. **Wait for approval**: Do not proceed until user confirms

**Example Interaction Pattern:**
```
Step 1 Complete: [Summary of what was done]
Next Step: [What will be done next]
Remaining Steps: [List of remaining steps]
Do you want me to continue with the next step?
```

This ensures transparency and allows for course correction at any point in the development process.

### 7. File Modification Guidelines

**Prohibited Modifications**:
- Do not modify core build files without explicit permission
- Avoid changing Omnibus packaging without understanding impact
- Do not alter CI/CD workflows without review
- Preserve existing dependency versions unless specifically required

**Safe Modifications**:
- Add new components in appropriate directories
- Update documentation and README files
- Add new tests and test fixtures
- Modify code in `components/` following patterns

### 8. Technology-Specific Guidelines

#### Ruby Components
- Follow Ruby style guidelines
- Use Bundler for dependency management
- Write RSpec tests for new functionality
- Maintain Gemfile.lock integrity

#### Go Components
- Follow Go conventions and formatting
- Use Go modules for dependency management
- Write standard Go tests
- Ensure cross-platform compatibility

#### Omnibus Packaging
- Understand software definitions before modifying
- Test package builds locally when possible
- Verify dependency chains
- Update version constraints carefully

### 9. Quality Assurance

- **Code Review**: Ensure code follows project patterns
- **Security**: Check for security vulnerabilities
- **Performance**: Consider performance implications
- **Compatibility**: Maintain backward compatibility
- **Documentation**: Keep documentation current

### 10. Communication Guidelines

- Use clear, concise commit messages
- Provide detailed PR descriptions with HTML formatting
- Include relevant Jira ticket references
- Explain technical decisions in code comments
- Update relevant documentation

### 11. Release and Build Pipeline Awareness

- **Expeditor Integration**: The project uses Expeditor for automated builds and releases
- **Build Channels**: Packages flow through `unstable` → `current` → `stable` channels
- **Critical Files**: 
  - `omnibus_overrides.rb`: Version pinning for dependencies (DO NOT MODIFY without explicit permission)
  - `.expeditor/config.yml`: Build and release automation configuration
  - `components/gems/Gemfile.lock`: Dependency management (use `rake update` task for updates)
- **Slack Integration**: Build notifications go to `#chef-ws-notify` channel

### 12. Dependency Management Guidelines

**Ruby Dependencies:**
- Use `bundle _2.1.4_ lock --update --add-platform ruby x64-mingw32 x86-mingw32 x64-mingw-ucrt` for Gemfile.lock updates
- Pin security-critical gems (OpenSSL ≥ 3.2.0 for FIPS mode support)
- Maintain compatibility with Ruby 3.1.7 (current version)

**Go Dependencies:**
- Use standard Go module management
- Ensure cross-platform compatibility (Windows, macOS, Linux)
- Use Habitat Studio for development environment

**Version Constraints:**
- Use `>=` for floors to prevent downgrades
- Use `~>` only for bug workarounds or temporary tech debt
- Equality pin critical gems (chef, chef-bin, etc.)

### 13. Code Quality and Standards

**Style Guidelines:**
- Ruby: Use Chefstyle (RuboCop) - run `rake style`
- Go: Follow standard Go formatting conventions
- All code must pass existing linting and style checks

**Testing Framework Usage:**
- Ruby: Minitest (~> 5.16), RSpec for behavior-driven tests
- Go: Built-in testing package with cross-platform considerations
- Integration: Test Kitchen with multiple drivers (Azure, EC2, Docker, etc.)

### 14. Security and Compliance

- **CVE Awareness**: Keep security gems updated (e.g., rdoc ~> 6.4.1 for CVE-2024-27281)
- **FIPS Compliance**: Maintain OpenSSL 3.2.0+ for FIPS mode support
- **License Compliance**: All files must include Apache 2.0 license headers

### 15. Platform-Specific Considerations

**Windows Support:**
- Include Windows-specific gems when `RUBY_PLATFORM.match?(/mswin|mingw|windows/)`
- Test with both x64-mingw32 and x64-mingw-ucrt platforms
- Ensure MSI packaging works correctly

**Cross-Platform Requirements:**
- Test on Ubuntu 18.04 (CI environment)
- Support macOS (dmg packaging)
- Maintain Linux compatibility

### 16. Code Ownership and Review Process

**CODEOWNERS Structure:**
- Default reviewers: `@chef/chef-workstation-owners`, `@chef/chef-workstation-approvers`, `@chef/chef-workstation-reviewers`
- Special areas:
  - `.expeditor/`: `@chef/jex-team`
  - Documentation: `@chef/docs-team`
  - Internationalization: `@chef/user-experience`

**Review Requirements:**
- All PRs require review from appropriate teams
- Expeditor files require JEX team approval
- Documentation changes need docs team review

### 17. Build Environment Setup

**Local Development:**
- Use Habitat Studio for Go components development
- Ruby development requires proper Bundler setup
- Cross-platform compilation available via `build_cross_platform` helper

**Omnibus Packaging:**
- Local builds: `sudo bin/omnibus build chef-workstation`
- Kitchen-based builds available for multiple platforms
- Clean builds: `bin/omnibus clean chef-workstation --purge`

### 18. Issue Templates and Bug Reporting

When creating issues, use appropriate templates:
- `BUG_TEMPLATE.md` for bug reports
- `ENHANCEMENT_REQUEST_TEMPLATE.md` for feature requests
- `DESIGN_PROPOSAL.md` for architectural changes
- `SUPPORT_QUESTION.md` for user support

### 19. Critical Dependencies to Monitor

**Core Chef Components:**
- Chef Infra Client (≥ 18.2)
- Chef InSpec (~> 5)
- Chef CLI (≥ 5.3.1)
- Test Kitchen (≥ 3.0)

**Cloud Integration:**
- Kitchen drivers: Azure, EC2, DigitalOcean, Docker, Google, Hyper-V, OpenStack, Vagrant, vCenter, vRealize
- Knife plugins: Azure, EC2, Google, Windows, vCenter, vSphere, vRealize

## Example Workflow Execution

```
User: "Implement feature X with Jira ticket ABC-123"

Copilot Response:
1. Fetching Jira details for ABC-123...
2. Analysis complete: [summary of requirements]
3. Implementation plan: [detailed steps]
4. Ready to start Phase 1? Next: Code Implementation → Testing → PR Creation
```

## Important Development Notes

- **All work is performed locally** - No remote development environments required
- **Never modify prohibited files** - Always check file modification guidelines
- **Maintain test coverage > 80%** - This is a hard requirement for the repository
- **Use meaningful commit messages** - Include Jira ID and clear description of changes
- **Follow established patterns** - Look at existing implementations for consistency
- **Test thoroughly** - Both unit tests and integration testing when possible
- **Document changes** - Update relevant documentation and add inline comments
- **Ask for clarification** - If requirements are unclear, ask for more details before proceeding

## Available Build Commands

**Ruby Components:**
- `rake style` - Run Chefstyle (RuboCop) linting
- `rake update` - Update Gemfile.lock with latest dependencies
- `bundle install` - Install Ruby dependencies

**Go Components:**
- `go test ./...` - Run all Go tests
- `go build` - Build Go components
- `hab studio enter` - Enter Habitat Studio for Go development

**Omnibus Packaging:**
- `sudo bin/omnibus build chef-workstation` - Build full package
- `bin/omnibus clean chef-workstation --purge` - Clean all build artifacts

This structured approach ensures consistent, high-quality contributions to the Chef Workstation project while maintaining proper testing coverage, security standards, and documentation requirements.
