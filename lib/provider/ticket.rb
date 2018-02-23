module TaskMapper::Provider
  module Pivotal
    class Ticket < TaskMapper::Provider::Base::Ticket
        extend TaskMapper::Provider::PivotalAccessor

      def initialize(*object)
        if object.first
          object = object.first


          unless object.is_a? Hash
            @system_data = {:client => object}

            hash = {
              :id => object.id,
              :issuetype => object.kind.downcase,
            #   :parent => object.label, #default
              :title => object.name,
              :created_at => object.created_at,
              :updated_at => object.updated_at,
              :description => object.description,
              :url => object.url
              }
            if object.kind.downcase == "epic"
              hash[:full_id] = object.label.id
            else
              unless object.estimate.nil?
                hash[:estimate] = object.estimate.prettify.to_s
              end
              unless object.current_state.nil?
                hash[:status] = object.current_state
              end
              if (object.labels || []).any?
                hash[:parent] = object.labels.first.id
              end
            end

          else
            hash = object
          end

          super(hash)
        end
      end


      def self.create(*options)
        options = options.first if options.is_a? Array
	    project = pivotal_client.project(options[:project_id])

        if options[:issuetype] == "epic"
          opts = {
            :name => options[:title],
            :description => options[:description]
          }

          begin
            epic = project.create_epic opts
            self.new epic
          rescue TrackerApi::Error => e
            response = e.instance_variable_get(:@response)
            body = response[:body]
            msg = "Pivotal Error: #{body['general_problem']}"

            raise TaskMapper::Exception.new(msg)
          end

        else
          opts = {
            :name => options[:title],
            :description => options[:description]
          }

          opts[:estimate] = options[:estimate] if options.has_key? :estimate
          opts[:current_state] = options[:status] if options.has_key? :status

          unless options.has_key? :parent && !options[:parent].blank?
            parent = options[:parent]
            opts[:label_ids] = parent unless parent.nil?
          end

          begin
            story = project.create_story opts

            self.new story
          rescue TrackerApi::Error => e
            response = e.instance_variable_get(:@response)
            body = response[:body]
            msg = "Pivotal Error: #{body['general_problem']}"

            raise TaskMapper::Exception.new(msg)
          end
        end
      end


      # Public: Saves a Ticket/Story to Pivotal Tracker
      #
      # Returns a boolean indicating whether or not the Story saved
      def save
        if @system_data and (story = @system_data[:client]) and story.respond_to?(:attributes)
            story.name = title if self.send(:title) != story.send(:name)
            story.description = description if self.send(:description) != story.send(:description)
            if issuetype == "story"
                story.estimate = estimate if self.send(:estimate) != story.send(:estimate)
                if self.send(:status) != story.send(:current_state)
                  story.current_state = status
                  if story.send(:accepted_at).present? && self.send(:status).to_s != "accepted"
                    story.accepted_at = nil
                  end
                end
            end
        end
        begin
          story.save
        rescue TrackerApi::Error => e
          response = e.instance_variable_get(:@response)
          body = response[:body]
          msg = "Pivotal Error: #{body['general_problem']}"

          raise TaskMapper::Exception.new(msg)
        end
      end

      # Public: Destroys the Ticket/Story in Pivotal Tracker
      #
      # Returns whether or not the Story was destroyed
      def destroy
        @system_data[:client].delete #.destroy.is_a?(Net::HTTPOK)
      end

      def self.find_by_attributes(project_id, attributes = {})
        search_by_attribute(self.find_all(project_id), attributes)
      end

      def self.find_by_id(project_id, id)
        self.find_all(project_id).find { |ticket| ticket.id == id }
      end

      def self.find_all(project_id)
        project = pivotal_client.project(project_id)

        epics = project.epics.map do |ticket|
          self.new ticket
        end


        stories = project.stories.map do |ticket|
          self.new ticket
        end
        epics + stories
      end

    end
  end
end

class Float
  def prettify
    to_i == self ? to_i : self
  end
end
