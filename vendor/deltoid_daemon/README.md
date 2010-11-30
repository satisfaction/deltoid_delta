## Deltoid Daemon

The deltoid daemon keeps your sphinx indexes up to date in near real-time. It does this by polling memcached, looking 
for dirty flags that tell it when the indexes ned to be rebuilt. It is expected to be used alongside Thinking Sphinx and the `deltoid_delta` gem, which sets the dirty flags in memcached whenever you change your indexed Active Record models.


