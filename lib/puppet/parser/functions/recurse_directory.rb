require 'find'

module Puppet::Parser::Functions
    # expects an args containing:
    # args[0] 
    # - The source module and directory inside of templates
    # - We will insert templates/ after the module name in this code
    # - required: true
    #
    # args[1]
    # - The destination directory for the interpolated templates to
    # - go on the client machine
    # - required: true
    #
    # args[2]
    # - The file mode for the finished files on the client
    # - required: false
    # - default: 0600
    #
    # args[3]
    # - The owner of the file
    # - required: false
    # - default: owner of puppet running process
    #
    # args[4]
    # - The group ownership of the file
    # - required: false
    # - default: owner of puppet running process
    #
    # args[5]
    # - The directory mode
    # - required: false
    # - default: 0700
    #
    # args[6]
    # - Flag used to merge only erb templates.
    # - required: false
    # - default: false
    #

    newfunction(:recurse_directory, :type => :rvalue) do |args|
    source_dir      = args[0]
    destination_dir = args[1]
    file_mode       = args[2]
    file_owner      = args[3]
    file_group      = args[4]
    dir_mode        = args[5]
    merge_erb_only  = args[6]


    file_path       = Puppet::Parser::Files.find_template(source_dir, compiler.environment)

    creatable_resources = Hash.new

    creatable_resources[destination_dir] = {
        'ensure'  => 'directory',
        'mode'    => dir_mode,
        'owner'   => file_owner,
        'group'   => file_group
    }

    Find.find(file_path) do |f|
        full_path = f
        f.slice!(file_path + "/")
        if f == file_path or f == '' or !f
            next
        end

        if not File.directory?("#{file_path}/#{f}")
          title = f.gsub(/\.erb$/,'')
          debug("File in loop #{f}")
          debug("Title in loop #{title}")
          destination_full_path = "#{destination_dir}/#{title}"
          file = "#{file_path}/#{f}"

          if merge_erb_only and title == f
            # The file is not a template (ie : not erb file).
            creatable_resources[destination_full_path] = {
                'ensure'  => 'file',
                'source'  => file,
                'mode'    => file_mode,
                'owner'   => file_owner,
                'group'   => file_group
            }
          else
            # The file is a template
            debug "Retrieving template #{file}"

            wrapper = Puppet::Parser::TemplateWrapper.new(self)
            wrapper.file = file
            begin
              wrapper.result
            rescue => detail
              info = detail.backtrace.first.split(':')
            raise Puppet::ParseError,
                "Failed to parse template #{file}:\n  Filepath: #{info[0]}\n  Line: #{info[1]}\n  Detail: #{detail}\n"
            end
            template_content = wrapper.result

            creatable_resources[destination_full_path] = {
                'ensure'  => 'file',
                'content' => template_content,
                'mode'    => file_mode,
                'owner'   => file_owner,
                'group'   => file_group
            }
            debug("Resource: #{destination_full_path} #{file_mode}")
          end

        elsif File.directory?("#{file_path}/#{f}") and f != '.' and f != '..'

          title = f
          destination_full_path = "#{destination_dir}/#{title}"
          creatable_resources[destination_full_path] = {
              'ensure'  => 'directory',
              'mode'    => dir_mode,
              'owner'   => file_owner,
              'group'   => file_group
          }
          debug("Resource: #{destination_full_path} #{dir_mode}")

        end

    end
    debug("Source Dir #{source_dir}")
    debug("Destination Dir #{destination_dir}")
    debug("File Path #{file_path}")
    creatable_resources
  end


end