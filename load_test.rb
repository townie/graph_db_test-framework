require 'neo4j'
require 'pry'
require 'sinatra'

use Rack::Session::Pool, :expire_after => 2592000

puts "stuff"

neo = Neo4j::Session.open(:server_db)


def create_datum
  "{ document_id:\"#{SecureRandom.base64}\",service_id:\"21\",document_type:\"folder\",published:\"2014-09-04T03:24:01.128Z\",updated:\"2015-01-09T18:45:16.279Z\",viewed:\"foo5\",google_quota_bytes_used:0,title:\"My Drive\",author:\"html'test@backupifydevman1.com\",last_editor:\"HTML\\u0026Test'汉字first \\\"HTML\\u0026TestçLast\",folders:\"[]\",mime_type:\"application/vnd.google-apps.folder\",content_url:\"foo14\",access_control_list:[{\"role_value:\"owner\",scope_type:\"user\",scope_value:\"html'test@backupifydevman1.com\"}],changestamp:\"foo123\",folder_ids:\"{}\",deleted:\"foo6543\",is_my_drive:true,size:\"foo235678\",stored_content_size:\"foo6789\",stored_api_response_size:\"foo098\",raw_content_digest:\"foo7890\",stored_content_digest:\"foo8666666\",raw_api_response_digest:\"foo555555\",stored_api_response_digest:\"foo666666\",content_md5_checksum:\"foo8888668665657\",owners:[\"HTML\\u0026Test'汉字first \\\"HTML\\u0026TestçLast\"],is_native_google_document:\"true\" }"
end

get '/:value' do
  value =   params[:value].to_i
  binding.pry
  value.times do |va|
    neo.query("CREATE (n:GoogleDriveItem  #{create_datum} ")
      puts "insert"
  end

end
# binding.pry
