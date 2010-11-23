namespace :thinking_sphinx do
  
  desc "Marks all indexes as stale, forcing a delta reindex"
  task :mark_indexes_as_stale => :app_env do
    require 'deltoid_delta'
    DeltoidDelta.mark_indexes_as_stale
  end
  
end

namespace :ts do
  desc "Marks all indexes as stale, forcing a delta reindex"
  task :mark => "thinking_sphinx:mark_indexes_as_stale"
end
