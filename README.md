puppet-recursive_directory
==========================

Puppet module to allow for files to be created recursively from a folder of templatees

usage
=====
```
recursive_directory {'some_unique_title':
      source_dir => 'custom_module/source_dir',
      final_dir  => '/tmp',
      file_mode  => '0644',
      owner      => 'root',
      group      => 'root
}
```
> This will copy all files from <module_path>custom_module/templates/source_dir folder
> and interpolate variables the same as when using the template() function inside of the
> manifest itself
