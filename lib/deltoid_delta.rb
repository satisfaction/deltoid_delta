require 'thinking_sphinx'
require 'thinking_sphinx/deltas/datetime_delta'

class DeltoidDelta < ThinkingSphinx::Deltas::DatetimeDelta
  
  def initialize(index, options = {})
    super
    
    index.sources.first.options[:sql_query_killlist] ||=
      "SELECT #{index.model.connection.quote_column_name(index.model.primary_key_for_sphinx)} " +
      "FROM #{index.model.quoted_table_name} " +
      "WHERE #{self.clause(index.model, true)}"
  end
  
  def index(model, instance = nil)
    self.class.mark_index_as_stale(model, instance)
  end
  
  # ===== STALE FLAG ===================================================================================================
  
  def self.stale_cache_key_for(model, instance = nil)
    "#{ActiveSupport::Inflector.underscore(model.name)}_index_is_stale"
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