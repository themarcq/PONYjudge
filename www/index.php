<?

include('libs.php');
$GLOBALS = new globals;
$STORAGE = new storage;
$TEMPLATE = new template;
$USER = new user;
$GLOBALS->loadConfig('config.ini');
$GLOBALS->loadUrl();
$STORAGE->connect() or $TEMPLATE->showError('Could not connect to STORAGE!');
$USER->auth();
$TEMPLATE->showMenuItem('lol','ilokampf.pl');
$TEMPLATE->choose($GLOBALS->RequestedPage);
$TEMPLATE->show();
$STORAGE->disconnect();

?>
