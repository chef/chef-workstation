+++
title = "knife search"
draft = false

gh_repo = "chef-workstation"

aliases = ["/knife_search.html", "/knife_search/"]

[menu]
  [menu.workstation]
    title = "knife search"
    identifier = "chef_workstation/chef_workstation_tools/knife/knife_search.md knife search"
    parent = "chef_workstation/chef_workstation_tools/knife"
+++
<!-- markdownlint-disable-file MD024 MD036 -->

{{< readfile file="content/reusable/md/search.md" >}}

{{< readfile file="content/workstation/reusable/md/knife_search_summary.md" >}}

## Syntax

This subcommand has the following syntax:

``` bash
knife search INDEX SEARCH_QUERY
```

where `INDEX` is one of `client`, `environment`, `node`, `role`, or the
name of a data bag and `SEARCH_QUERY` is the search query syntax for the
query that will be executed.

`INDEX` is implied if omitted, and will default to `node`. For example:

``` bash
knife search '*:*' -i
```

will return something similar to:

``` bash
8 items found

centos-62-dev
opensuse-15
ubuntu-1804-orgtest
ubuntu-1804-ohai-test
ubuntu-1804-ifcfg-test
ohai-test
win2k19-dev
```

and is the same search as:

``` bash
knife search node '*:*' -i
```

If the `SEARCH_QUERY` does not contain a colon character (`:`), then the
default query pattern is
`tags:*#{@query}* OR roles:*#{@query}* OR fqdn:*#{@query}* OR addresses:*#{@query}*`,
which means the following two search queries are effectively the same:

``` bash
knife search ubuntu
```

or:

``` bash
knife search node "tags:*ubuntu* OR roles:*ubuntu* OR fqdn:*ubuntu* (etc.)"
```

### Query Syntax

{{< readfile file="content/reusable/md/search_query_syntax.md" >}}

### Keys

{{< readfile file="content/reusable/md/search_key.md" >}}

To search for the available fields for a particular object, use the
`show` argument with any of the following knife subcommands:
`knife client`, `knife data bag`, `knife environment`, `knife node`, or
`knife role`. For example: `knife data bag show`.

#### Nested Fields

{{< readfile file="content/reusable/md/search_key_nested.md" >}}

#### Examples

{{< readfile file="content/reusable/md/search_key_name.md" >}}

{{< readfile file="content/reusable/md/search_key_wildcard_question_mark.md" >}}

{{< readfile file="content/reusable/md/search_key_wildcard_asterisk.md" >}}

{{< readfile file="content/reusable/md/search_key_nested_starting_with.md" >}}

{{< readfile file="content/reusable/md/search_key_nested_range.md" >}}

### About Patterns

{{< readfile file="content/reusable/md/search_pattern.md" >}}

#### Exact Matching

{{< readfile file="content/reusable/md/search_pattern_exact.md" >}}

{{< readfile file="content/reusable/md/search_pattern_exact_key_and_item.md" >}}

{{< readfile file="content/reusable/md/search_pattern_exact_key_and_item_string.md" >}}

#### Wildcard Matching

{{< readfile file="content/reusable/md/search_pattern_wildcard.md" >}}

{{< readfile file="content/reusable/md/search_pattern_wildcard_any_node.md" >}}

{{< readfile file="content/reusable/md/search_pattern_wildcard_node_contains.md" >}}

#### Range Matching

{{< readfile file="content/reusable/md/search_pattern_range.md" >}}

{{< readfile file="content/reusable/md/search_pattern_range_in_between.md" >}}

{{< readfile file="content/reusable/md/search_pattern_range_exclusive.md" >}}

#### Fuzzy Matching

{{< readfile file="content/reusable/md/search_pattern_fuzzy.md" >}}

{{< readfile file="content/reusable/md/search_pattern_fuzzy_summary.md" >}}

### About Operators

{{< readfile file="content/reusable/md/search_boolean_operators.md" >}}

{{< readfile file="content/reusable/md/search_boolean_operators_andnot.md" >}}

#### AND

{{< readfile file="content/reusable/md/search_boolean_and.md" >}}

#### NOT

{{< readfile file="content/reusable/md/search_boolean_not.md" >}}

#### OR

{{< readfile file="content/reusable/md/search_boolean_or.md" >}}

### Special Characters

{{< readfile file="content/reusable/md/search_special_characters.md" >}}

## Options

{{< note >}}

{{< readfile file="content/workstation/reusable/md/knife_common_see_common_options_link.md" >}}

{{< /note >}}

This subcommand has the following options:

`-a ATTR`, `--attribute ATTR`

: The attribute (or attributes) to show.

`-b ROW`, `--start ROW`

: The row at which return results begin.

`-f FILTER`, `--filter-result FILTER`

: Use to filter the search output based on the pattern that matc the specified `FILTER`. Only attributes in the `FILTER` will returned. For example: `\"ServerName=name, Kernel=kernel.version\`.

`-i`, `--id-only`

: Show only matching object IDs.

`INDEX`

: The name of the index to be queried: `client`, `environment`, `node`, `role`, or `DATA_BAG_NAME`. Default index: `node`.

`-l`, `--long`

: Display all attributes in the output and show the output as JSON.

`-m`, `--medium`

: Display normal attributes in the output and to show the output as JSON.

`-q SEARCH_QUERY`, `--query SEARCH_QUERY`

: Protect search queries that start with a hyphen (-). A `-q` query may be specified as an argument or an option, but not both.

`-r`, `--run-list`

: Show only the run-list.

`-R INT`, `--rows INT`

: The number of rows to be returned.

`SEARCH_QUERY`

: The search query used to identify a list of items on a Chef Infra Server. This option uses the same syntax as the `search` subcommand.

## Examples

The following examples show how to use this knife subcommand:

**Search by platform ID**

{{< readfile file="content/workstation/reusable/md/knife_search_by_platform_ids.md" >}}

**Search by instance type**

{{< readfile file="content/workstation/reusable/md/knife_search_by_platform_instance_type.md" >}}

**Search by recipe**

{{< readfile file="content/workstation/reusable/md/knife_search_by_recipe.md" >}}

**Search by cookbook, then recipe**

{{< readfile file="content/workstation/reusable/md/knife_search_by_cookbook.md" >}}

**Search by node**

{{< readfile file="content/workstation/reusable/md/knife_search_by_node.md" >}}

**Search by node and environment**

{{< readfile file="content/workstation/reusable/md/knife_search_by_node_and_environment.md" >}}

**Search for nested attributes**

{{< readfile file="content/workstation/reusable/md/knife_search_by_nested_attribute.md" >}}

**Search for multiple attributes**

{{< readfile file="content/workstation/reusable/md/knife_search_by_query_for_many_attributes.md" >}}

**Search for nested attributes using a search query**

{{< readfile file="content/workstation/reusable/md/knife_search_by_query_for_nested_attribute.md" >}}

**Use a test query**

{{< readfile file="content/workstation/reusable/md/knife_search_test_query_for_ssh.md" >}}
