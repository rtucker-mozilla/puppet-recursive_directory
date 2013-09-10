define recursive_directory (
    $source_dir = undef,
    $dest_dir = undef,
    $file_mode = '0600',
    $owner = 'nobody',
    $group = 'nobody',
){
    if $source_dir and $dest_dir {
        $resources_to_create = recurse_directory(
            $source_dir,
            $dest_dir,
            $file_mode,
            $owner,
            $group
            )
        notice($resources_to_create)
        create_resources('file', $resources_to_create)
    } else {
        fail("source_dir and dest_dir are required")
    }

}
