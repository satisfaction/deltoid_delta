require 'thinking_sphinx'
require 'thinking_sphinx/deltas/datetime_delta'

class DeltoidDelta < ThinkingSphinx::Deltas::DatetimeDelta
  
  def index(model, instance = nil)
    self.class.mark_index_as_stale(model, instance)
  end
  
  # ===== STALE FLAG ===================================================================================================
  
  def self.stale_cache_key_for(model, instance = nil)
    "#{model.name.underscore}_is_stale"
  end
  
  def self.mark_index_as_stale(model, instance = nil)
    Rails.cache.write(stale_cache_key_for(model, instance), 1)
  end
  
  def self.mark_indexes_as_stale
    ThinkingSphinx.context.indexed_models.each do |model_class_name|
      mark_index_as_stale(model_class_name.constantize, nil)
    end
  end
  
end