require File.dirname(__FILE__) + '/spec_helper.rb'

SPHINX_CONFIG = <<-SPHINX
  indexer
  {
  }

  searchd
  {
    listen = 127.0.0.1:9312
    log = /log/searchd.log
    query_log = /log/searchd.query.log
    pid_file = /log/searchd.development.pid
  }

  source person_core_0
  {
    type = mysql
    sql_host = localhost
    sql_user = root
    sql_pass = 
    sql_db = graystone_development
    sql_query_pre = SET NAMES utf8
    sql_query_pre = SET TIME_ZONE = '+0:00'
    sql_query = SELECT SQL_NO_CACHE `people`.`id` * 4 + 2 AS `id` , `people`.`name` AS `name`, `people`.`id` AS `sphinx_internal_id`, 1013574116 AS `class_crc`, 0 AS `sphinx_deleted`, UNIX_TIMESTAMP(`people`.`created_at`) AS `created_at` FROM `people`    WHERE `people`.`id` >= $start AND `people`.`id` <= $end GROUP BY `people`.`id`  ORDER BY NULL
    sql_query_range = SELECT IFNULL(MIN(`id`), 1), IFNULL(MAX(`id`), 1) FROM `people` 
    sql_attr_uint = sphinx_internal_id
    sql_attr_uint = class_crc
    sql_attr_uint = sphinx_deleted
    sql_attr_timestamp = created_at
    sql_query_info = SELECT * FROM `people` WHERE `id` = (($id - 2) / 4)
  }

  index person_core
  {
    source = person_core_0
    path = /db/sphinx/development/person_core
    charset_type = utf-8
  }

  source person_delta_0 : person_core_0
  {
    type = mysql
    sql_host = localhost
    sql_user = root
    sql_pass = 
    sql_db = graystone_development
    sql_query_pre = 
    sql_query_pre = SET NAMES utf8
    sql_query_pre = SET TIME_ZONE = '+0:00'
    sql_query = SELECT SQL_NO_CACHE `people`.`id` * 4 + 2 AS `id` , `people`.`name` AS `name`, `people`.`id` AS `sphinx_internal_id`, 1013574116 AS `class_crc`, 0 AS `sphinx_deleted`, UNIX_TIMESTAMP(`people`.`created_at`) AS `created_at` FROM `people`    WHERE `people`.`id` >= $start AND `people`.`id` <= $end AND `people`.`updated_at` > DATE_SUB(NOW(), INTERVAL 1800 SECOND) GROUP BY `people`.`id`  ORDER BY NULL
    sql_query_range = SELECT IFNULL(MIN(`id`), 1), IFNULL(MAX(`id`), 1) FROM `people` WHERE `people`.`updated_at` > DATE_SUB(NOW(), INTERVAL 1800 SECOND)
    sql_attr_uint = sphinx_internal_id
    sql_attr_uint = class_crc
    sql_attr_uint = sphinx_deleted
    sql_attr_timestamp = created_at
    sql_query_info = SELECT * FROM `people` WHERE `id` = (($id - 2) / 4)
  }

  index person_delta : person_core
  {
    source = person_delta_0
    path = /db/sphinx/development/person_delta
  }

  index person
  {
    type = distributed
    local = person_delta
    local = person_core
  }

  source robot_core_0
  {
    type = mysql
    sql_host = localhost
    sql_user = root
    sql_pass = 
    sql_db = garystone_development
    sql_query_pre = UPDATE `robots` SET `updated_at` = 0 WHERE `updated_at` = 1
    sql_query_pre = SET SESSION group_concat_max_len = 1048576
    sql_query_pre = SET NAMES utf8
    sql_query_pre = SET TIME_ZONE = '+0:00'
    sql_query = SELECT SQL_NO_CACHE `robots`.`id` * 4 + 3 AS `id` , `robots`.`model` AS `model`,, `robots`.`id` AS `sphinx_internal_id`, 1552019743 AS `class_crc`, 0 AS `sphinx_deleted`, UNIX_TIMESTAMP(CONVERT_TZ(robots.created_at, '+00:00', @@session.time_zone)) AS `created_at`, UNIX_TIMESTAMP(CONVERT_TZ(robots.updated_at, '+00:00', @@session.time_zone)) AS `updated_at` FROM `robots` WHERE `robots`.`id` >= $start AND `robots`.`id` <= $end GROUP BY `robots`.`id`  ORDER BY NULL
    sql_query_range = SELECT IFNULL(MIN(`id`), 1), IFNULL(MAX(`id`), 1) FROM `robots` 
    sql_attr_uint = sphinx_internal_id
    sql_attr_uint = class_crc
    sql_attr_uint = sphinx_deleted
    sql_attr_timestamp = created_at
    sql_attr_timestamp = updated_at
    sql_query_info = SELECT * FROM `robots` WHERE `id` = (($id - 3) / 4)
  }

  index robot_core
  {
    source = robot_core_0
    path = /db/sphinx/development/robot_core
    charset_type = utf-8
  }

  source robot_delta_0 : robot_core_0
  {
    type = mysql
    sql_host = localhost
    sql_user = root
    sql_pass = 
    sql_db = satisfaction_development
    sql_query_pre = 
    sql_query_pre = SET NAMES utf8
    sql_query_pre = SET TIME_ZONE = '+0:00'
    sql_query = SELECT SQL_NO_CACHE `robots`.`id` * 4 + 3 AS `id` , `robots`.`model` AS `model`,, `robots`.`id` AS `sphinx_internal_id`, 1552019743 AS `class_crc`, 0 AS `sphinx_deleted`, UNIX_TIMESTAMP(CONVERT_TZ(robots.created_at, '+00:00', @@session.time_zone)) AS `created_at`, UNIX_TIMESTAMP(CONVERT_TZ(robots.updated_at, '+00:00', @@session.time_zone)) AS `updated_at` FROM `robots` WHERE `robots`.`id` >= $start AND `robots`.`id` <= $end GROUP BY `robots`.`id`  ORDER BY NULL
    sql_query_range = SELECT IFNULL(MIN(`id`), 1), IFNULL(MAX(`id`), 1) FROM `topics` WHERE `topics`.`updated_at` > DATE_SUB(NOW(), INTERVAL 86400 SECOND)
    sql_attr_uint = sphinx_internal_id
    sql_attr_uint = class_crc
    sql_attr_uint = sphinx_deleted
    sql_attr_timestamp = created_at
    sql_attr_timestamp = updated_at
    sql_query_info = SELECT * FROM `topics` WHERE `id` = (($id - 3) / 4)
  }

  index robot_delta : robot_core
  {
    source = topic_delta_0
    path = /db/sphinx/development/robot_delta
  }

  index robot
  {
    type = distributed
    local = robot_delta
    local = robot_core
  }

SPHINX

describe Deltoid do
  
  before :each do
    DaemonKit.arguments = DaemonKit::Arguments.new
  end
  
  # ===== SPHINX CONFIG ================================================================================================
  
  describe "#sphinx_config_file" do
    
    describe "when explicitly set" do
      
      before :each do
        @deltoid = Deltoid.new("development.sphinx.conf")
      end
      
      it "should return the set value" do
        @deltoid.sphinx_config_file.should == "development.sphinx.conf"
      end
      
    end
    
    describe "when not set" do
      
      before :each do
        DaemonKit.arguments.options[:sphinx_config_file] = 'custom.sphinx.conf'
        @deltoid = Deltoid.new
      end
      
      it "should default to the :sphinx_config_file argument" do
        @deltoid.sphinx_config_file.should == "custom.sphinx.conf"
      end
      
    end
    
  end
  
  describe "sphinx_pid" do
    
    before :each do
      @deltoid = Deltoid.new
    end
    
    describe "when sphinx is running" do
      
      before :each do
        @deltoid.should_receive(:`).with("pgrep searchd").and_return("4321\n")
      end
      
      it "should return the pid" do
        @deltoid.sphinx_pid.should == 4321
      end
      
    end
    
    describe "when sphinx is not running" do
      
      before :each do
        @deltoid.should_receive(:`).with("pgrep searchd").and_return("\n")
      end
      
      it "should return nil" do
        @deltoid.sphinx_pid.should == nil
      end
      
    end
    
  end
  
  describe "sphinx_client" do
    
    describe "when a sphinx configuration is present" do
      
      before :each do
        @deltoid = Deltoid.new("sphinx.conf")
        File.should_receive(:read, "sphinx.conf").and_return(SPHINX_CONFIG)
      end
      
      it "should return a Riddle::Client with the server and port in the config" do
        Riddle::Client.should_receive(:new).with('127.0.0.1', 9312)
        @deltoid.sphinx_client
      end
      
    end
    
    describe "when a sphinx configuration is not present" do
      
      before :each do
        @deltoid = Deltoid.new
      end
      
      it "should return a default Riddle::Client" do
        Riddle::Client.should_receive(:new).with()
        @deltoid.sphinx_client
      end
      
    end
    
  end
  
  # ===== INDEXES ======================================================================================================
  
  describe "#delta_index_prefixes" do
    
    before :each do
      @deltoid = Deltoid.new("sphinx.conf")
      File.should_receive(:read, "sphinx.conf").and_return(SPHINX_CONFIG)
    end
    
    it "should extract delta index names from the sphinx config" do
      @deltoid.delta_index_prefixes.should == %w[person robot]
    end
    
  end
  
  describe "#stale_index_prefixes" do
    
    before :each do
      @deltoid = Deltoid.new
      @deltoid.should_receive(:delta_index_prefixes).and_return(%w[person robot beast])
      
      @deltoid.should_receive(:cache_get).with("person_index_is_stale").and_return(1)
      @deltoid.should_receive(:cache_get).with("robot_index_is_stale").and_return(nil)
      @deltoid.should_receive(:cache_get).with("beast_index_is_stale").and_return("1")
    end
    
    it "should iterate through each delta index and return which are stale" do
      @deltoid.stale_index_prefixes.should == %w[person beast]
    end
    
  end
  
  # ===== CACHE ========================================================================================================
  
  describe "#memcached_config_file" do
    
    describe "when explicitly set" do
      
      before :each do
        @deltoid = Deltoid.new(nil, "memcached.yml")
      end
      
      it "should return the set value" do
        @deltoid.memcached_config_file.should == "memcached.yml"
      end
      
    end
    
    describe "when not set" do
      
      before :each do
        DaemonKit.arguments.options[:memcached_yml_file] = 'custom.memcached.yml'
        @deltoid = Deltoid.new
      end
      
      it "should default to the :memcached_yml_file argument" do
        @deltoid.memcached_config_file.should == 'custom.memcached.yml'
      end
      
    end
    
  end
  
  describe "#cache" do
    
    describe "when no memcached config was provided" do
      
      it "should contact a local memcached on the default port" do
        MemCache.should_receive(:new).with('localhost:11211', :multithread => true)
        Deltoid.new.cache
      end
      
    end
    
    describe "when a memached config is available" do
      
      before :each do
        @deltoid = Deltoid.new(nil, "memcached.yml")
        
        @defaults = {
          'multithread' => true
        }
        
        ::YAML.should_receive(:load_file, 'memcached.yml').and_return({
          'development' => {
            'servers' => [ 'localhost:11211' ]
          },
          'test' => {
            'servers' => [ 'localhost:11211', 'localhost:11212' ],
            'timeout' => 2.0
          },
          'defaults' => {
            'multithread' => true
          }
        })
      end
      
      it "should use the options for the current environment, merged with the 'defaults' config" do
        DAEMON_ENV.should == 'test'
        
        MemCache.should_receive(:new).with('localhost:11211', 'localhost:11212', :multithread => true, :timeout => 2.0)
        @deltoid.cache
      end
      
    end
    
  end
  
  # ===== REINDEXING ===================================================================================================
  
  describe "run_indexer_for_stale_indexes" do
    
    before :each do
      @deltoid = Deltoid.new("sphinx.conf")
    end
    
    describe "when the indexer is successful" do
      
      before :each do
        @deltoid.should_receive(:sphinx_running?).and_return(false)
        @deltoid.should_receive(:`).with("indexer  --config \"sphinx.conf\" person_delta beast_delta")
        
        $?.should_receive(:exitstatus).and_return(0)
      end
      
      it "should return true" do
        @deltoid.run_indexer_for_stale_indexes(%w[person beast]).should == true
      end
      
    end
    
    describe "when the indexer fails" do
      
      before :each do
        @deltoid.should_receive(:sphinx_running?).and_return(false)
        
        @deltoid.should_receive(:`).with("indexer  --config \"sphinx.conf\" person_delta beast_delta")
        $?.should_receive(:exitstatus).and_return(1)
      end
      
      it "should return false" do
        @deltoid.run_indexer_for_stale_indexes(%w[person beast]).should == false
      end
      
    end
    
    describe "when sphinx is running" do
      
      before :each do
        @deltoid.should_receive(:sphinx_running?).and_return(true)
      end
      
      it "should run the indexer with the --rotate flag" do
        @deltoid.should_receive(:`).with("indexer --rotate --config \"sphinx.conf\" person_delta beast_delta")
        @deltoid.run_indexer_for_stale_indexes(%w[person beast])
      end
      
    end
    
  end
    
  describe "#reindex_main_indexes" do
    
    before :each do
      @deltoid = Deltoid.new("sphinx.conf")
      @deltoid.should_receive(:delta_index_prefixes).and_return(%w[person robot beast])
      %w[person robot beast].each do |index_prefix|
        @deltoid.should_receive(:clear_stale_index_with_prefix, index_prefix)
      end
    end
    
    describe "when sphinx is running" do
      
      before :each do
        @deltoid.should_receive(:sphinx_running?).and_return(true)
      end
      
      it "should ask the indexer to rotate the indexes" do
        @deltoid.should_receive(:`).with("indexer --config \"sphinx.conf\" --rotate --all")
        @deltoid.reindex_main_indexes!
      end
      
    end
    
    describe "when sphinx is not running" do
      
      before :each do
        @deltoid.should_receive(:sphinx_running?).and_return(false)
      end
      
      it "should not ask the indexer to rotate the indexes" do
        @deltoid.should_receive(:`).with("indexer --config \"sphinx.conf\"  --all")
        @deltoid.reindex_main_indexes!
      end
      
    end
    
    describe "when the indexer is successful" do
      
      before :each do
        @deltoid.should_receive(:sphinx_running?).and_return(true)
        @deltoid.should_receive(:`).with("indexer --config \"sphinx.conf\" --rotate --all")
        $?.should_receive(:exitstatus).and_return(0)
      end
      
      it "should return true" do
        @deltoid.reindex_main_indexes!.should == true
      end
      
    end
    
    describe "when the indexer fails" do
      
      before :each do
        @deltoid.should_receive(:sphinx_running?).and_return(true)
        @deltoid.should_receive(:`).with("indexer --config \"sphinx.conf\" --rotate --all")
        $?.should_receive(:exitstatus).and_return(1)
      end
      
      it "should return false" do
        @deltoid.reindex_main_indexes!.should == false
      end
      
    end
    
  end
  
end
