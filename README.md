puppet-recursive_directory
==========================

Puppet module to allow for files to be created recursively from a folder of templatees

usage
=====
```
recursive_directory {'some_unique_title':
      source_dir => 'custom_module/folder_in_templates',
      final_dir  => '/tmp',
      file_mode  => '0644',
      owner      => 'root',
      group      => 'root
}
```
