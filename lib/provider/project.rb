module TicketMaster::Provider
  module Pivotal
    # Project class for ticketmaster-pivotal
    # 
    # 
    class Project < TicketMaster::Provider::Base::Project
      # The finder method
      # 
      # It accepts all the find functionalities defined by ticketmaster
      #
      # + find() and find(:all) - Returns all projects on the account
      # + find(<project_id>) - Returns the project based on the id
      # + find(:first, :name => <project_name>) - Returns the first project based on the attribute
      # + find(:name => <project name>) - Returns all projects based on the attribute
      attr_accessor :prefix_options
      alias_method :stories, :tickets
      alias_method :story, :ticket
      
      def self.find(*options)
        first = options.shift
        if first.nil? or first == :all
          PivotalAPI::Project.find(:all).collect do |p|
            self.new p
          end
        elsif first.is_a?(Fixnum)
          self.new PivotalAPI::Project.find(first)
        elsif first == :first
          self.new self.search(options.shift || {}, 1).first
        elsif first.is_a?(Hash)
          self.search(first).collect { |p| self.new p }
        end
      end
      
      # This is a helper method to find
      def self.search(options = {}, limit = 1000)
        projects = PivotalAPI::Project.find(:all)
        projects.find_all do |p|
          options.keys.reduce(true) do |memo, key|
            p.send(key) == options[key] and (limit-=1) >= 0
          end
        end
      end
      
      # Create a project
      def self.create(*options)
        project = PivotalAPI::Project.new(options.shift)
        project.save
        self.new project
      end
      
      # The initializer
      #
      # A side effect of Hashie causes prefix_options to become an instance of TicketMaster::Provider::Pivotal::Project
      def initialize(*options)
        @system = :pivotal
        @system_data = {}
        first = options.shift
        if first.is_a?(PivotalAPI::Project)
          @system_data[:client] = first
          @prefix_options = first.prefix_options
          super(first.attributes)
        else
          super(first)
        end
      end
      
      # All tickets for this project
      def tickets(*options)
        if options.length == 0
          Ticket.find(:project_id => self.id)
        else
          first = options.first
          if first.is_a?(Fixnum)
            [Ticket.find(first, {:project_id => self.id})]
          else
            Ticket.find({:project_id => self.id}.merge(:q => options.first))
          end
        end
      end
      
      # The ticket finder
      # returns only one ticket
      def ticket(*options)
        first = options.shift
        if first.nil?
          return Ticket
        elsif first.is_a?(Fixnum)
          return Ticket.find(first, :project_id => self.id)
        else
          Ticket.find(:first, {:project_id => self.id}.merge(:q => first))
        end
      end
      
      # Save this project
      def save
        warn 'Warning: Pivotal does not allow editing of project attributes. This method does nothing.'
        true
      end
      
      # Delete this project
      def destroy
        result = self.system_data[:client].destroy
        result.is_a?(Net::HTTPOK)
      end

    end
  end
end