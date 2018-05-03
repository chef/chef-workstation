# Chef Workstation + http://chef.sh

Chef Workstation hosts its marketing and documentation content on [chef.sh](https://chef.sh) (the microsite) along with marketing and documentation for other Chef products including Chef Server, Chef Client, and ChefDK. The primary source code for [chef.sh](https://chef.sh) is kept with the [chef/chef-www](https://github.com/chef/chef-www) code along with most of the marketing materials, but the documentation source is kept with the code repositories. To handle this, we have a dedicated code structure here in `chef/chef-workstation` that is pulled into `chef/chef-www` when it is updated.

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
: Pull down the current chef.sh content and chef-www submodule (for the chef-sh theme)

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
