# Chef Workstation Documentation

This folder contains the source for the [Chef Workstation documentation](https://docs.chef.io/workstation/)
which is deployed on the [Chef Documentation](https://docs.chef.io) site using a Hugo module.

## The fastest way to contribute

The fastest way to change the documentation is to edit a page on the
GitHub website using the GitHub UI.

To perform edits using the GitHub UI, click on the `[edit on GitHub]` link at
the top of the page that you want to edit. The link takes you to that topic's GitHub
page. In GitHub, click on the pencil icon and make your changes. You can preview
how they'll look right on the page ("Preview Changes" tab).

We also require contributors to include their [DCO signoff](https://github.com/chef/chef/blob/master/CONTRIBUTING.md#developer-certification-of-origin-dco)
in the comment section of every pull request, except for obvious fixes. You can
add your DCO signoff to the comments by including `Signed-off-by:`, followed by
your name and email address, like this:

`Signed-off-by: Julia Child <juliachild@chef.io>`

See our [blog post](https://blog.chef.io/introducing-developer-certificate-of-origin/)
for more information about the DCO and why we require it.

After you've added your DCO signoff, add a comment about your proposed change,
then click on the "Propose file change" button at the bottom of the page and
confirm your pull request. The CI system will do some checks and add a comment
to your PR with the results.

The Chef documentation team can normally merge pull requests within seven days.
We'll fix build errors before we merge, so you don't have to
worry about passing all the CI checks, but it might add an extra
few days. The important part is submitting your change.

## Local Development Environment

We use [Hugo](https://gohugo.io/), [Go](https://golang.org/), and[NPM](https://www.npmjs.com/)
to build the Chef Documentation website. You will need Hugo 0.78.1 or higher
installed and running to build and view our documentation properly.

To install Hugo, NPM, and Go on Windows and macOS:

- On macOS run: `brew install hugo node go`
- On Windows run: `choco install hugo nodejs golang`

To install Hugo on Linux, run:

- `apt install -y build-essential`
- `snap install node --classic --channel=12`
- `snap install hugo --channel=extended`

## Preview Workstation Documentation

There are two ways to preview the documentation in `chef-workstation`:

- submit a PR
- `make serve`

### Submit a PR

When you submit a PR to `chef-workstation`, Netlify will build the documentation
and add a notification to the GitHub pull request page. You can review your
documentation changes as they would appear on docs.chef.io.

### make serve

Running `make serve` will clone a copy of `chef/chef-web-docs` into `docs-chef-io`.
That copy will be configured to build the Workstation documentation from `docs-chef-io`
and live reload if any changes are made while the Hugo server is running.

- Run `make serve`
- go to http://localhost:1313

#### Clean Your Local Environment

If you have a local copy of chef-web-docs cloned into `docs-chef-io`,
running `make clean_all` will delete the SASS files, node modules, and fonts in
`docs-chef-io/chef-web-docs/themes/docs-new` used to
build the docs site in the cloned copy of chef-web-docs. Hugo will reinstall these
the next time you run `make serve`.

## Creating New Pages

Please keep all of the Workstation documentation in the `www/content/workstation` directory.
To add a new Markdown file, run the following command from the `www` directory:

```
hugo new content/workstation/<filename>.md
```

This will create a draft page with enough front matter to get you going.

Hugo uses [Goldmark](https://github.com/yuin/goldmark) which is a
superset of Markdown that includes GitHub styled tables, task lists, and
definition lists.

See our [Style Guide](https://docs.chef.io/style_guide/) for more information
about formatting documentation using Markdown.


### Local Content

```
.
├── docs-chef-io
│   ├── content
│   │   ├── workstation                 # where to keep markdown file documentation
|   ├── static
|   |   ├── images
|   |   |   ├── chef-workstation        # where to keep any images you need to reference in your documentation
```

### What is happening behind the scenes

The [Chef Documentation](https://docs.chef.io) site uses [Hugo modules](https://gohugo.io/hugo-modules/)
to load content directly from the `docs-chef-io` directory in the `chef/chef-workstation`
repository. Every time `chef/chef-workstation` is released to stable, Expeditor
instructs Hugo to update the version of the `chef/chef-workstation` repository
that Hugo uses to build Chef Workstation documentation on the [Chef Documentation](https://docs.chef.io)
site. This is handled by the Expeditor subscriptions in the `chef/chef-web-docs` GitHub repository.

## Documentation Feedback

We love getting feedback, questions, or comments.

**Email**

Send an email to Chef-Docs@progress.com for documentation bugs,
ideas, thoughts, and suggestions. This email address is not a
support email address. If you need support, contact [Chef Support](https://www.chef.io/support/).

**GitHub issues**

Submit an issue to the [Workstation repo](https://github.com/chef/chef-workstation/issues)
for "important" documentation bugs that may need visibility among a larger group,
especially in situations where a doc bug may also surface a product bug.

Submit an issue to [chef-web-docs](https://github.com/chef/chef-web-docs/issues) for
doc feature requests and minor documentation issues.