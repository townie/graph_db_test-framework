# load "/Users/backupifyadmin/backupify/neo4j-load-test/child_of.rb", true

class GoogleDriveItem
  include Neo4j::ActiveNode

  property :document_id, constraint: :unique
  property :service_id, default: "foo1"
  property :document_type, default: "foo2"
  property :updated, default: "foo4"
  property :title, default: "foo7"
  property :author, default: "foo8"
  property :last_editor, default: "foo9"
  property :folders, default: "foo12"
  property :folder_ids, default: {"foo12324" =>"bar"}
  property :is_my_drive, default: "foo76543"
  property :stored_content_digest, default: "foo8666666"


  serialize :access_control_list
  serialize :folder_ids

  index :document_id

  has_many :out, :parents, model_class: GoogleDriveItem, rel_class: ::ChildOf

  def set_parent(parent, since)
    ::ChildOf.create(from_node: self, to_node: parent, since: since)
  end

  def children(time=Time.now.to_i)
    time.to_datetime.to_i unless time.is_a?(Integer)

    candidates = query_as(:parent).match('parent<-[rel:child_of]-(child)').where("rel.since < #{time}").pluck(:rel)

    rels = candidates.inject({}) do |hash,rel|
      doc_id = rel.from_node.document_id
      if hash.has_key?(doc_id) && (rel.since > hash[doc_id].since)
        hash[doc_id] = rel
      else
        hash[doc_id] = rel
      end

      hash
    end

    rels.values.map(&:from_node)
  end


  # # def root
  #    @root ||= Neo4j.query("MATCH (item:GoogleDriveItem) WHERE  (item.title = 'My Drive') AND item.service_id = 21
  #                           AND item.folder_ids = {}  AND item.folders = []
  #                           RETURN item").first
  # #   #  self.class.where(:service_id => self.service_id, :folder_ids => {}, :folders => []).to_a
  # # end
  # def root_node
  #   @root_node ||= GoogleDriveItem.as(:item).where("item.is_my_drive? = true AND item.service_id = #{self.service_id}").to_a.first
  # end

  def insert_into_graph
    node = fetch_node_with_document_id

    if node.nil?
      self.save
      node = self
    else
      node = transfer_attr(node,self)
    end
    parents = locate_parent_object(node)

    parents.each do |parent|
      node.set_parent(parent, Time.now.to_i)
    end

    node
  end

  def root_item?
    self.folder_ids.empty? && self.folders.empty? && (self.title == "My Drive")
  end

  def hierarchy(time=Time.now.to_i)
    time = time.to_datetime.to_i unless time.is_a?(Integer)

    h = children(time).inject({}) do |hash,child|
      hash[child.title] = child.hierarchy(time)
      hash
    end

    if h.empty?
      document_id
    else
      h
    end
  end

private

  def label_from_mime(node)
    node.add_label(node.document_type)
  end

  def transfer_attr(to_node,from_node)
    attrs = to_node.attributes.keys
    attrs.each do |attr|
      to_node[attr] = from_node[attr]
    end
    to_node.save
    to_node
  end

  def fetch_node_with_document_id
    ::GoogleDriveItem.find_by(:document_id => self.document_id)
  end

  def locate_parent_object(node)
    parent_ids = node.folder_ids.try(:keys)

    # returns only in case of my_drive
    return [] if node.is_my_drive?

    parents = parent_ids.map do |pid|
      begin
        ::GoogleDriveItem.find_by(:document_id => pid)
      rescue => e

      end
    end

    parents.compact!

    if parents.empty?
      parents = create_dummy_parent(parent_ids)
    end

    parents
  end

  def create_dummy_parent(parent_ids)
    parent_ids.map do |pid|
      ::GoogleDriveItem.create(:document_id => pid)
    end
  end
end

require './child_of'
