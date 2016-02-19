module TaskMapper::Provider
  module Pivotal
    # Project class for taskmapper-pivotal
    #
    #
    class Project < TaskMapper::Provider::Base::Project
      extend TaskMapper::Provider::PivotalAccessor

      # Public: Creates a new Project based on passed arguments
      #
      # args - hash of Project values
      #
      # Returns a new Project
      def initialize(*object)
        if object.first
          object = object.first
          unless object.is_a? Hash
            @system_data = {:client => object}
            hash = {:id => object.id,
                    :name => object.name,
                    :description => object.description,
                    :updated_at => object.updated_at,
                    :created_at => object.created_at}
          else
            hash = object
          end
          super(hash)
        end
      end

      # Public: Copies tickets/comments from one Project onto another.
      #
      # project - Project whose tickets/comments should be copied onto self
      #
      # Returns the updated project
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(
            :name => ticket.title,
            :description => ticket.description
          )
          ticket.comments.each do |comment|
            copy_ticket.comment!(:text => comment.body)
            sleep 1
          end
        end
      end

      def self.find_by_attributes(attributes = {})
        search_by_attribute(self.find_all, attributes)
      end

      def self.find_all
        pivotal_client.projects.map { |project|
          Project.new project
        }
      end

      def self.find_by_id(id)
        project = pivotal_client.project(id)
        Project.new project unless project.nil?
      end
    end
  end
end
