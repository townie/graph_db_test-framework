require 'neo4j'
require 'pry'
require 'sinatra'
require 'orientdb4r'

use Rack::Session::Pool, :expire_after => 2592000

puts "stuff"

neo = Neo4j::Session.open(:server_db)

DB = 'foo'
CLASS = 'myclass'


def client
  Orientdb4r.client  # equivalent for :host => 'localhost', :port => 2480, :ssl => false
end

if client.database_exists? :database => DB, :user => 'admin', :password => 'password'
  client.create_database :database => DB, :storage => :memory, :user => 'root', :password => 'password'
end

client.connect :database => DB, :user => 'root', :password => 'password'



def create_datum
   id = SecureRandom.base64
  "{ document_id: '#{id}',service_id: '21',document_type: 'folder',published: '2014-09-04T03:24:01.128Z',updated: '2015-01-09T18:45:16.279Z',title: 'My Drive',author: 'test@backupifydevman1.com',folders: '[]',mime_type: 'application/vnd.google-apps.folder',folder_ids: [],is_my_drive:true,content_md5_checksum: 'foo8888668665657' }"
end

get '/neo/:value' do
  value =   params[:value].to_i
  value
  start_time = Time.now

  threads = []
  100.times do
    threads << Thread.new do
      value.times do |va|
        neo.query("CREATE (n:GoogleDriveItem  #{create_datum} ) ")
        print "."
      end
    end
  end
  threads.each { |thr| thr.join }
  elapsed_time  = start_time - Time.now

  elapsed_time.to_s
end
# binding.pry

get '/orient/:value' do
  binding.pry
  value = params[:value].to_i
 # # binding.pry
 #  unless client.class_exists? CLASS
 #    puts "creating class myClass"
 #    client.create_class(CLASS) do |c|
 #      c.property 'prop1', :integer, :notnull => true, :min => 1, :max => 99
 #      c.property 'prop2', :string, :mandatory => true
 #      c.link     'users', :linkset, 'OUser' # by default: :mandatory => false, :notnull => false
 #    end
 #  end
  # admin = client.query("SELECT FROM OUser WHERE name = 'admin'")[0]

  start_time = Time.now

  threads = []
  100.times do
    threads << Thread.new do
      (1..value).each do |val|
        client.connect :database => DB, :user => 'root', :password => 'password'

        client.command "INSERT INTO #{CLASS} (prop1, prop2, users) VALUES (#{val}, 'text#{val}', #5:0)"
        print "."
      end
    end
  end
  threads.each { |thr| thr.join }
  elapsed_time  = start_time - Time.now

  elapsed_time.to_s
end
