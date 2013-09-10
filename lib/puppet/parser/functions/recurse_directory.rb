require 'puppet'

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
    # - default: nobody
    #
    # args[4]
    # - The group ownership of the file
    # - required: false
    # - default: nobody
    #
    newfunction(:recurse_directory, :type => :rvalue) do |args|
    source_dir = args[0]
    destination_dir = args[1]
    file_mode = args[2]
    if not file_mode or file_mode == ''
        file_mode = '0600'
    end
    file_owner = args[3]
    if not file_owner
        file_owner = 'nobody'
    end
    file_group = args[4]
    if not file_group
        file_group = 'nobody'
    end
    creatable_resources = Hash.new
    source_dir_array = source_dir.split(/\//)
    template_path = source_dir_array[0]
    #
    # insert /templates to the modulename as our base search path
    #
    source_dir_array[0] = "#{source_dir_array[0]}/templates"
    search_path = source_dir_array.join('/')

    moduledir = Puppet[:modulepath].split(/:/)[0]
    file_path = "#{moduledir}/#{search_path}"
    files_found = Dir.entries(file_path)
    ensure_mode = 'file'
    files_found.each do |f|
        if f == '.' or f == '..'
            next
        end
        title = f.gsub(/\.erb$/,'')
        debug("File in loop #{f}")
        debug("Title in loop #{title}")
        destination_full_path = "#{destination_dir}/#{title}"
        file = "#{template_path}/#{f}"
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
            'ensure' => ensure_mode,
            'content' => template_content,
            'owner' => file_owner,
            'group' => file_group,
            'mode' => file_mode,
        }

    end
    debug("Source Dir #{source_dir}")
    debug("Destination Dir #{destination_dir}")
    debug("Module Dir #{moduledir}")
    debug("File Path #{file_path}")
    debug("Files Found #{files_found}")
    debug("Creatable Resources #{creatable_resources}")
    return creatable_resources
    end

end
