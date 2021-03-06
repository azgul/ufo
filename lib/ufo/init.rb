module Ufo
  class Init < Sequence
    add_runtime_options! # force, pretend, quiet, skip options
      # https://github.com/erikhuda/thor/blob/master/lib/thor/actions.rb#L49

    # Ugly, this is how I can get the options from to match with this Thor::Group
    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:image, type: :string, required: true, desc: "Docker image name without the tag. Example: tongueroo/hi. Configures ufo/settings.yml"],
        [:app, type: :string, required: true, desc: "App name. Preferably one word. Used in the generated ufo/task_definitions.rb."],
      ]
    end
    cli_options.each do |args|
      class_option *args
    end

    # for specs
    def set_destination_root
      return unless ENV['UFO_ROOT']

      dest = ENV['UFO_ROOT']
      FileUtils.rm_rf(dest) && FileUtils.mkdir_p(dest)
      self.destination_root = dest
      FileUtils.cd(dest)
    end

    def init_files
      # map variables
      @app = options[:app]
      @image = options[:image]
      # copy the files
      puts "Setting up ufo project..."
      directory "."
    end

    def upsert_gitignore
      return unless File.exist?(".gitignore")
      append_to_file ".gitignore", <<-EOL
.ufo/output
.ufo/data
EOL
    end

    def user_message
      puts "Starter ufo files created."
      puts <<-EOL
#{"="*64}
Congrats 🎉 You have successfully set up ufo for your project. To deploy to ECS:

  ufo ship #{@app}-web

If you need to customize the ECS task definition to configure things like memory and cpu allocation. You can do this by adjusting the files the .ufo/variables folder. These variables get applied to the .ufo/templates/main.json.erb task definition json that is passed to the ECS register task definition api.

Some additional starter example roles for your apps were set up in in .ufo/task_definitions.rb.  Be sure to check it out and adjust it for your needs.

This allows you to fully customize and control your environment to fit your application's needs.

More info: http://ufoships.com
EOL
    end
  end
end
