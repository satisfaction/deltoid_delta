# deltoid_delta

Delta indexing plugin for Thinking Sphinx that sets a reindex flag in memcached whenever a model needs to be reindexed.
It is expected to be used along with the Deltoid daemon, which polls memcached and rebuilds indices whenever the reindex 
flags are set.

## Installation

Installation is as simple as adding the `deltoid_delta` gem to your Gemfile:

    gem 'deltoid_delta', :git => "git://github.com/satisfaction/deltoid_delta.git"

You may want to tag it to a specific release:

    gem 'deltoid_delta', :git => "git://github.com/satisfaction/deltoid_delta.git", :tag => "0.0.14"

Then bundle your gems:

    bundle install

You'll then need to require `deltoid_delta` in your Rails project. I've typically put this in an initializer along with
all my other Sphinx-related configuration.
  
    require 'deltoid_delta'

## Using deltoid_delta in your models

Thinking Sphinx allows you to specify which delta indexing strategy to use by setting the `:delta` property to the name
or instance of a class. Within your `define_index` block, set the property like so:

    set_property  :delta => "DeltoidDelta"

`deltoid_delta` is based on the datetime delta strategy, and supports all of the same options, such as `:threshold` and
`:delta_column`. The defaults for `:threshold` and `:delta_column` are also the same (1 day and `updated_at`,
respectively).

## The Deltoid Daemon process

All of the actual delta indexing work is performed within the deltoid daemon process, included in the gem. This daemon
will check a memcached server every second to see if a dirty flag has been set for an index. This dirty flag is
automatically set anytime one of your indexed models is updated.

Whenever the deltoid daemon notices your indexes are dirty, it will rebuild the delta indexes for you. It will first
clear the dirty flag, and then invoke the Sphinx `indexer` process to rebuild the affected indexes.

The deltoid daemon also performs a complete reindex of the indexes once a day at midnight. Having all your indexing in
one process avoids multiple indexer processes from corrupting your indexes.

### Rake Tasks

To properly manage your indexes, the deltoid daemon needs your Sphinx configuration file, as well as your memcached.yml
file. The `deltoid_delta` gem comes with rake tasks that you can use to manage the daemon process.

To use the rake tasks, you should include them in your Rakefile:

    require 'deltoid_delta/tasks'

This will give you the following rake tasks for managing the deltoid daemon included in the gem:

    rake deltoid:env      # Displays the calculated deltoid daemon configuration values
    rake deltoid:restart  # Restarts the deltoid daemon process
    rake deltoid:run      # Runs the deltoid daemon process in the foreground
    rake deltoid:start    # Starts the deltoid daemon process
    rake deltoid:stop     # Stops the deltoid daemon process

The `deltoid:env` task is really useful for debugging what the tasks will run, or as a starting point for writing your
own management scripts.

## Copyright

Copyright (c) 2010 Get Satisfaction. See LICENSE.txt for
further details.