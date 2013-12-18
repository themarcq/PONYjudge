<?

    include('libs.php');
    $globals = new globals;
    $storage = new storage;
    $template = new template;
    $user = new user;
    $globals->load_config('config.ini');
    $storage->connect($globals) or die('could not connect to storage!'); // <- essential!
    $user->auth($storage);

?>

<html>
    <head>
        <title><? echo $globals->websitetitle; ?></title>
    </head>
    <body>

    <?

        $template->show_header();
        $template->show_menu();
        $template->show_body();
        $template->show_footer();

    ?>

    </body>
</html>

<?

    $storage->disconnect();

?>
