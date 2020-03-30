# Chef Workstation + http://chef.sh

This folder contains the source for the [Chef Workstation documentation](https://docs.chef.io/workstation/). It is
copied and deployed via [chef/chef-www](https://github.com/chef/chef-www) as a Hugo module.

The primary source code for [chef.sh](https://chef.sh) (the microsite) is kept with the [chef/chef-www](https://github.com/chef/chef-www) repo along with most of the marketing materials.

## Getting Started

### One Time Install

1. Install Hugo

    ```
    $ brew install hugo
    ```

### Routine Setup

_These are the steps you'll need to run every time you launch a development environment._

1. From the `www` directory, run the following command to start the live-reload development environment. When this is running, any changes you make to content in the `www/content` directory will be automatically compiled and updated the browser.

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
├── www        # the hugo site directory used for local development
```

### Local Content
```
.
├── site
│   ├── content
│   │   ├── workstation             # where to keep markdown file documentation
│   ├── data
│   │   ├── chef-workstation        # where to keep structured data files used for data templates
│   ├── layouts
|   │   ├── shortcodes
|   │   │   ├── workstation         # how to name your workstation-specific shortcodes
|   ├── static
|   |   ├── images
|   |   |   ├── chef-workstation    # where to keep any images you need to reference in your documentation
|   |   ├── css
```

### What is happening behind the scenes

TODO

## Helpers

make assets
: TODO

make clean
: Reset the locally built site

make serve
: Start the live-reload development environment

## Markdown Content

Please keep all your documentation in the `content/workstation` directory. To add a new Markdown file, simply run the following command from the `www` directory:

```
hugo new content/workstation/<filename>.md
```

This will create the file and fill in the necessary frontmatter automatically.

If you add content it will not automatically show up on the sidebar. You can see this by serving the website locally,
going to the root page and search for anything with `Workstation Menu: False`.

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
