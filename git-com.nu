#!/usr/bin/nu
# if jsonnet is absent, stop.
if (which jsonnet) == [] {
    error make {
        msg: "failed to find jsonnet",
        code: "lefty::build_infra::cmd_not_found::jsonnet",
        labels: [{
            text: "this command depends on the presence of jsonnet"
        }],
        help: "try installing jsonnet",
        url: "https://jsonnet.org/"
    }
    exit 1
}

# Manifest a yaml document from the jsonnet spec
let yaml_doc: string  = ^jsonnet .git-com.jsonnet | from json

# Print the git-com configuration into the spec
echo $yaml_doc out> .git-com.yml

