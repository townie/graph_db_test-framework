# load "/Users/backupifyadmin/backupify/neo4j-load-test/google_drive_item.rb"
class ChildOf
  include Neo4j::ActiveRel

  from_class ::GoogleDriveItem
  to_class ::GoogleDriveItem
  type 'child_of'

  property :since, type: Integer

  validates_presence_of :since
end
