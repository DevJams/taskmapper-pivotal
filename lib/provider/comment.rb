module TaskMapper::Provider
  module Pivotal
    class Comment < TaskMapper::Provider::Base::Comment
      extend TaskMapper::Provider::PivotalAccessor

      def body
        self.text
      end

      def body=(string)
        self.text = string
      end

      def ticket_id
        self.story_id
      end

    #   class << self
      def self.find_by_id(project_id, ticket_id, id)
        find_by_attributes(project_id, ticket_id, :id => id).first
      end

      def self.find_by_attributes(project_id, ticket_id, attributes = {})
        search_by_attribute(find_all(project_id, ticket_id), attributes)
      end

      def self.find_all(project_id, ticket_id)
          
        story = TrackerApi::Resources::Story.new( client:     pivotal_client,
                                                project_id: project_id,
                                                id:         story_id)
        story.comments.collect { |note|
        self.new convert_to_comment(note, project_id, ticket_id)
        }
      end

      def create(attrs)
        #   attrs[:story_id] = attrs.delete(:ticket_id)
        #   attrs[:text] ||= (attrs.delete(:body) || attrs.delete('body'))

        #   note = PivotalAPI::Note.new(attrs)
        #   note.save

        #   self.new convert_to_comment note, attrs[:project_id], attrs[:story_id]
      end
        
    end
  end
end
