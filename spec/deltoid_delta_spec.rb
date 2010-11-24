require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "DeltoidDelta" do
  
  before :each do
    @model = stub('IndexedModel')
    @model.stub(:name => 'IndexedModel')
  end
  
  describe ".stale_cache_key_for" do
    
    it "should generate a memcache key using the name of the model" do
      DeltoidDelta.stale_cache_key_for(@model).should == "indexed_model_index_is_stale"
    end
    
  end
  
  describe ".mark_index_as_stale" do
    
    before :each do
      @cache = stub('cache')
      Rails = stub('rails')
      Rails.stub(:cache => @cache)
      
    end
    
    it "should set the delta flag in memcached" do
      @cache.should_receive(:write).with("indexed_model_index_is_stale", 1)
      DeltoidDelta.mark_index_as_stale(@model)
    end
    
  end
  
end
