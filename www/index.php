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
$TEMPLATE->showMenuItem('lel','ilokampf.pl');
$TEMPLATE->showMenuItem('jakiś dłuższy tekścik','ilokampf.pl');
$TEMPLATE->showMenuItem('więcej pól w menu!','ilokampf.pl');
$TEMPLATE->showError('Latający Potworze Spaghetti! Error!');
$TEMPLATE->choose($GLOBALS->RequestedPage);
$TEMPLATE->show();
$STORAGE->disconnect();

?>
