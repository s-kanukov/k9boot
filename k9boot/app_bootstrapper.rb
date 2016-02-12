require 'fileutils'
require 'yaml'
require_relative 'actions'

module K9Boot
  class AppBootstrapper
    include K9Boot::Actions

    DEFAULT_TEMPLATES_PATH = 'templates'.freeze

    DEFAULT_SHARED_TEMPLATES_PATH = 'shared'.freeze
    DEFAULT_SIMPLE_TEMPLATES_PATH = 'simple'.freeze
    DEFAULT_ADVANCED_TEMPLATES_PATH = 'advanced'.freeze

    DEFAULT_COPY_DIR = 'copy'.freeze
    DEFAULT_SNIPPETS_FILE = 'snippets.yml'.freeze
    DEFAULT_TASKS_FILE = 'tasks.yml'.freeze

    def initialize(app_path, app_type)
      @app_path = app_path
      @app_type = app_type
    end

    def bootstrap
      puts "\n", 'Bootstrapping your new application...'
      bootstrap_shared_templates
      bootstrap_specific_templates
    end

    private

    def bootstrap_shared_templates
      shared_templates_path = File.join(File.dirname(__FILE__),
                                        DEFAULT_TEMPLATES_PATH,
                                        DEFAULT_SHARED_TEMPLATES_PATH)
      bootstrap_copy_dirs shared_templates_path
      bootstrap_snippets shared_templates_path
      bootstrap_tasks shared_templates_path
    end

    def bootstrap_specific_templates
      specific_templates_path =
        if @app_type == :simple
          File.join(File.dirname(__FILE__),
                    DEFAULT_TEMPLATES_PATH,
                    DEFAULT_SIMPLE_TEMPLATES_PATH)
        else
          File.join(File.dirname(__FILE__),
                    DEFAULT_TEMPLATES_PATH,
                    DEFAULT_ADVANCED_TEMPLATES_PATH)
        end
      bootstrap_copy_dirs specific_templates_path
      bootstrap_snippets specific_templates_path
      bootstrap_tasks specific_templates_path
    end

    def bootstrap_copy_dirs(templates_path)
      dir_to_copy = File.join(templates_path, DEFAULT_COPY_DIR)
      return unless Dir.exist? dir_to_copy

      process_copy_dir(File.join(dir_to_copy, '.'), @app_path)
    end

    def bootstrap_snippets(templates_path)
      snippets_file = File.join(templates_path, DEFAULT_SNIPPETS_FILE)
      return unless File.exist? snippets_file

      yaml = YAML.load_file snippets_file
      yaml['snippets'].each do |file_snippet|
        process_file_insert file_snippet if file_snippet.key? 'insert'
        process_file_replace file_snippet if file_snippet.key? 'replace'
        process_file_delete file_snippet if file_snippet.key? 'delete'
      end
    end

    def bootstrap_tasks(templates_path)
      tasks_file = File.join(templates_path, DEFAULT_TASKS_FILE)
      return unless File.exist? tasks_file

      yaml = YAML.load_file tasks_file
      # run all tasks from created app dir
      Dir.chdir(@app_path) do
        yaml['tasks'].each do |task|
          process_task task
        end
      end
    end

    def process_copy_dir(dir_from, dir_to)
      FileUtils.cp_r(dir_from, dir_to)
    end

    def process_file_insert(file_snippet)
      file_path = File.join(@app_path, file_snippet['file'])
      file_snippet['insert'].each do |insert|
        case insert['where']
        when 'begin'
          prepend_to_file(file_path, insert['code'])
        when 'end'
          append_to_file(file_path, insert['code'])
        else
          insert_into_file(file_path, insert['code'],
                           insert['where'].to_sym => insert['selector'])
        end
      end
    end

    def process_file_replace(file_snippet)
      file_path = File.join(@app_path, file_snippet['file'])
      file_snippet['replace'].each do |replace|
        replace_in_file(file_path, replace['code'], replace['with'])
      end
    end

    def process_file_delete(file_snippet)
      file_path = File.join(@app_path, file_snippet['file'])
      file_snippet['delete'].each do |delete|
        delete_in_file(file_path, delete['code'])
      end
    end

    def process_task(task)
      system(task['task'])
    end
  end
end
