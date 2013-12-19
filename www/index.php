<?

    include('libs.php');
    $globals = new globals;
    $storage = new storage;
    $template = new template;
    $user = new user;
    $globals->load_config('config.ini');
    $storage->connect() or $template->show_error('Could not connect to storage!');
    $user->auth();
    $template->show();
    $storage->disconnect();

?>
