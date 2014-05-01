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
/* temporary! for testing */
$TEMPLATE->showMenuItem('lol','ilokampf.pl');
$TEMPLATE->showMenuItem('lel','ilokampf.pl');
$TEMPLATE->showMenuItem('jakiś dłuższy tekścik','ilokampf.pl');
$TEMPLATE->showMenuItem('więcej pól w menu!','ilokampf.pl');
$TEMPLATE->showMenuItem('PONY!','pony');
$TEMPLATE->showError('Latający Potworze Spaghetti! Error!');
/* ! temporary! for testing */
$TEMPLATE->choose($GLOBALS->RequestedPage);
$TEMPLATE->show();
$STORAGE->disconnect();

?>
