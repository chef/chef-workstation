# Chef Workstation + http://chef.sh

Chef Workstation hosts its marketing and documentation content on [chef.sh](https://chef.sh) (the microsite) along with marketing and documentation for other Chef products including Chef Server, Chef Client, and ChefDK. The primary source code for [chef.sh](https://chef.sh) is kept with the [chef/chef-www](https://github.com/chef/chef-www) code along with most of the marketing materials, but the documentation source is kept with the code repositories. To handle this, we have a dedicated code structure here in `chef/chef-workstation` that is pulled into `chef/chef-www` when it is updated.

## Getting Started

### One Time Install

1. **DISABLE SMART QUOTES**
   OS X is annoying and tries to use smartquotes when editing Hugo docs. You want smartquotes disabled regardless if you are writing code.
   Here's how [you can disable it](http://www.iclarified.com/38772/how-to-disable-curly-quotes-in-mac-os-x-mavericks).

1. Install the AWS CLI

    ```
    $ brew install awscli
    ```

1. Follow the instructions [here](https://github.com/chef/okta_aws#installation) to install and setup [okta_aws](https://github.com/chef/okta_aws).

    1. Run `okta_aws --list` and make sure you see `chef-cd` in the output.
    1. If you do not, please reach out to the #helpdesk and have them add you to the "Chef CD AWS Account".

1. Install Hugo

    ```
    $ brew install hugo
    ```

### Routine Setup

_These are the steps you'll need to run every time you launch a development environment._

1. Authentiate against the `chef-cd` AWS Account

    ```
    $ okta_aws chef-cd
    ```

1. From the `www` directory, run the following command to start the live-reload development environment. When this is running, any changes you make to content in the `www/site` directory will be automatically compiled and updated the browser.

    ```
    $ make serve
    ```

## Creating Blog Posts and Making Docs Changes

The site is built with [Hugo](https://gohugo.io/), a Go-based static site generator, and uses
[Stencil](https://stenciljs.com/) for web components and [Sass](http://sass-lang.com/) for CSS.
You'll probably want to familiarize yourself with the Hugo documentation, which covers templating,
layouts, functions, etc., but there are helpers to assist you with doing some common things, like
creating a new blog post:

```shell
cd site
hugo new blog/my-sweet-new-post.md
```

Your new post will be created as a draft with enough frontmatter to get you going. All content is authored
in [Markdown](https://en.wikipedia.org/wiki/Markdown).

## Structure

### High Level
```
.
├── Makefile    # contains helpers to quickly start up the development environment
├── README.md
├── chef-sh     # hidden directory that contains the pre-compiled source for chef.sh
├── chef-www    # chef/chef-www submodule to pull in the chef-sh theme for local development
├── site        # the hugo site directory used for local development
```

### Local Content
```
.
├── site
│   ├── content
│   │   ├── docs
│   │   │   ├── chef-workstation    # where to keep markdown file documentation
│   ├── data
│   │   ├── chef-workstation        # where to keep structured data files used for data templates
│   ├── layouts
|   │   ├── shortcodes
|   │   │   ├── cw-*                # how to name your workstation-specific shortcodes
|   ├── static
|   |   ├── images
|   |   |   ├── chef-workstation    # where to keep any images you need to reference in your documentation
```

### What is happening behind the scenes

Everytime a PR is merged into `chef/chef-workstation`, the contents of the `chef-workstation` directories from the `site` directory are synced to `chef/chef-www` and the `chef-www-acceptance.cd.chef.co` acceptance environment is automatically updated. This is handled by the Expeditor subscriptions in the `chef/chef-www` GitHub repository.

## Helpers

make sync
: Pull down the current chef.sh content and chef-hugo-theme submodule. You'll need [okta_aws](https://github.com/chef/okta_aws) configured and have access to the `chef-cd` profile.

make serve
: Start the live-reload development environment

## Markdown Content

Please try to keep all your documentation in the `chef-workstation` directory. Any new documents should automatically show up in the sidebar. If you need to control the ordering of the sidebar, you can add `weight` to the frontmatter of the documents.

To add a new Markdown file, simply run the following command from the `www/site` directory:

```
hugo new docs/chef-workstation/<filename>.md
```

This will create the file and fill in the necessary frontmatter automatically.

## Data Content

Hugo allows us to nest our data directory structure as much as necessary. You can add as many folders as necessary under `site/data/chef-workstation`, Expeditor will sync them all into `chef/chef-www`.

```
.
├── site
│   ├── data
│   │   ├── chef-workstation
|   │   │   ├── cli
|   |   │   │   ├── command_one.yml
|   |   │   │   └── command_two.yml
```

## Shortcode Content

[Shortcodes](https://gohugo.io/content-management/shortcodes/) are how we inject non-markdown content into markdown pages. This is especially useful when you want to inject read in data files, parse them, and then inject them into one or more Markdown pages. Since Hugo does not supported a nested directory structure, you'll need to prefix all your chef-workstation shortcodes with `cw-` when you use them.

For example, below is how you can use a shortcode in a Markdown page to inject CLI documentation generated using a Data file.

```
+++
title = "CLI"
weight = 10
[menu]
  [menu.docs]
    parent = "Chef Workstation"
+++

Below you'll find all our amazing Chef Workstation CLI documentation!

{{< cw-cli-documentation >}}
```
