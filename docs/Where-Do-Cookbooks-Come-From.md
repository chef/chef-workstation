## Providing Cookbooks to Chef Server

There are three methods for getting cookbooks onto the server:

### Knife / Chef Server API

 - knife upload COOKBOOK/PATH and knife cookbook upload NAME allow cookbooks to be uploaded.
 - Dependencies are not automatically uploaded - user must do so manually. It's possible to bulk-upload
   many cookbooks this way.

### Berkshelf

 -  A berksfile provides a convenient method to manage cookbook dependencies. Operator creates a Berksfile
 from multiple potential sources to local cache
 - on berks upload, the pinned versions of all cookbooks (direct and dependencies) are uploaded to Chef Server.
 - dependencies are resolved by default with gecode, though berks offers an option to resolve
   with a different resolver. This should be safe, but it is possible that this resolver may resolve
   deps differently than gecode (used by chef-server).  So when a run_list is posted to the server,
   dependencies may fail to resolve on the client.


### Policyfile

- user creates policy file  that specifies cookbook sources, cookbook version constraints, runlist, override and normal attributes.
- user runs `chef policy install`
  - pull all required cookbooks into cache from the specified
  - resolve deps using `solve` gem, same as the alternate to gecode that berks uses.
  - generates Policyfile.lock.json
- user runs `chef push`. This will upload the policy lock to a policy group, and upload
  the cookbooks required by policyfile.lock out of cache. The policy and group will be created if it doesn't exist.
- policy is assigned to a node(s) by updating the nodes to reference the policy group and file.
- Policy lock is uploaded to the server for the nodes; all cb versions are uploaded. At
  run-time, chef-client still uses the cookbook server for download; but it does not send a run list
  to the server for resolution. Instead, it downloads the CB versions specified in the lock file.

## Supported Cookbook Sources


## Runtime Cookbook Resolution (chef-client)

### Method: Chef Infra Server

This includes any case where a node's runlist is managed in absense of policy group/file.

 - run list is expanded and merged in client:
   - starts from run list saved to node;  OR override run-list from the CLI
   - roles are resolved to the recipes they contain and added to the run list
   - environment run lists are expanded as above, and added to the run list.
   - No dependency eval is done by the client.
 - client posts the expanded run list to the server for dependency resolution.
   - endpoint: `environments/$/run_list`
   - server evaluates the run list against the full list of available cookbooks for the org
     including dependencies
      * replies with the cookbooks & versions needed to solve the expanded run list, respecting
        version constraints
      * this reply becomes node["cookbooks"] and represents the cookbooks required for the expanded run list
        it is a full snapshot of cookbooks in use by the node as of most recent converge.  (Saved when converge is complete)
 - client downloads cookbooks into client cache at the version provided in the runlist.
 - converge continues

### Method: Policyfile

 - client downloads policyfile lock
 - determine run list from policyfile lock
 - determine cookbook list from policyfile lock
 - download cookbooks to cache
 - converge continues

### Method: Effortless

 - this follows the same path as policyfile, except that the chef-server used to fetch cookbooks
   is chef-zero.
