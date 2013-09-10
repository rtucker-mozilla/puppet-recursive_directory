class recursive_directory::test {
    $final_dir = '/tmp/blah'
    file {$final_dir:
        ensure => directory,
        recurse => true,
        purge => true,
    }
    recursive_directory{'recursive_something':
        source_dir => 'recursive_directory',
        final_dir  => $final_dir,
        owner      => 'root',
        group      => 'root',
        require    => File[$final_dir]
    }
}
