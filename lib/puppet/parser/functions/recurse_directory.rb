require 'puppet'

module Puppet::Parser::Functions
    debug_mode = true
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
        if debug_mode
            notice("File in loop #{f}")
            notice("Title in loop #{title}")
        end
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
    if debug_mode
        notice("Source Dir #{source_dir}")
        notice("Destination Dir #{destination_dir}")
        notice("Module Dir #{moduledir}")
        notice("File Path #{file_path}")
        notice("Files Found #{files_found}")
        notice("Creatable Resources #{creatable_resources}")
    end
    return creatable_resources
    end

end
