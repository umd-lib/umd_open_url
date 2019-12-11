# umd_open_url

## Introduction

This project provides a simple mechanisms for:

* creating an OpenURL hyperlink
* querying an OpenURL resolver service

As there is no standard response format to an OpenURL request, this project
only supports the WorldCat Knowledge Base API - OpenURL Resolve service.

This implementation is intentionally simple, and likely does not support most
OpenURL scenarios. See the "[openurl](https://github.com/openurl/openurl)" is
likely a better choice.

## Functionality

### OpenURL Builder

The UmdOpenUrl::Builder class provides a fluent interface for creating an
OpenURL hyperlink.

#### Sample Usage - Builder

```
require 'umd_open_url'

UmdOpenUrl::Builder.new('https://worldcat.org/webservices/kb/openurl/resolve')
b.custom_param('wskey', 'REPLACE_ME').issn('0022-4812').volume(1).start_page(40).publication_date(1936-03-01)

url = b.build

puts url
# https://worldcat.org/webservices/kb/openurl/resolve?wskey=REPLACE_ME&rft.issn=0022-4812&rft.volume=1&rft.spage=40&rft.date=1936-03-01
```

### OpenURL Resolver

The UmdOpenUrl::Resolver class contains two methods:

* resolve(open_url) - Queries the OpenURL resolver service, and parses the
response as JSON. An unsuccessful query returns nil.
* parse_response(json) - Parses JSON to return the first "linkerurl", or nil
if there is no "linkerurl" property or an error occurs.

**Note:** The "linkerurl" is peculiar to the World OpenURL Resolve service,
so this will likely not work with other OpenURL resolve services.

#### Sample Usage - Resolver

```
json_response = UmdOpenUrl::Resolver.resolve(open_url_link)
link = UmdOpenUrl::Resolver.parse_response(json_response)
```

## Assumptions

The tool makes the following assumptions:

1) All the files in the source directory on the source server are candidates
for transfer.

2) The source server can identify the files to transfer by comparing the
source directory on the source server and the destination directory on
the destination server. Any files/subdirectories not in the destination
directory will be transferred.

## Requirements

* This gem has been tested with Ruby v2.3

## Installation

This tool is implemented as a Ruby gem, but is not available from the
rubygems.org archive. To install this gem as a command-line tool on a server,
do the following:

1) Configure the "gem" command to use the UMD Nexus, instead of rubygems.org as
the repository:

    a) Add the Nexus "umd-ruby-gems-repository-group" as a source:

    ```
    > gem sources --add https://maven.lib.umd.edu/nexus/content/groups/umd-ruby-gems-repository-group/
    ```

    b) Remove the "RubyGems.org" source:

    ```
    > gem sources --remove https://rubygems.org/
    ```

    c) Clear the cache:

    ```
    > gem sources -c
    ```

2) Install the "umd_open_url" gem:

    Note: This will add multiple gems into the current gemset.

    ```
    > gem install umd_open_url
    ```

## Publishing the Gem

To publish the new version to the UMD Nexus, do the following:

1) Install the "nexus" gem:

    ```
    > gem install nexus
    ```

Note: This command only needs to be run once.

2) To publish the gem:

    a) Run "rake install" to build the gem:

    ```
    > rake install
    ```

    This will create a gem file in "pkg" subdirectory.

    b) Switch to the "pkg" subdirectory:

    ```
    > cd pkg
    ```

    c) Use the "gem nexus" command, where <GEM_FILE> is the gem filename:

    ```
    gem nexus --url https://maven.lib.umd.edu/nexus/content/repositories/gem-releases <GEM_FILENAME>
    ```

    For example, if the filename of the gem is umd_open_url-0.1.0.gem, the
command would be:

   ```
   > gem nexus --url https://maven.lib.umd.edu/nexus/content/repositories/gem-releases umd_open_url-0.1.0.gem
   ```

    **Note:** The URL is for the "UMD Libraries Gem" Nexus repository, not the "umd-ruby-gems-repository-group" repository group.

    Also, currently the "UMD Libraries Gem" Nexus repository is configured to
    not allow "redeploys". If the gem has updated, the version number for the
    gem also needs to be updated.

## License

See the [LICENSE](LICENSE) file for license rights and limitations
(Apache 2.0).
