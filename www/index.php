<?
include('globals.php'); // global variables
$global= new global;
include('libs.php'); //libraries
$storage=new storage;
$storage->connect($global); // connect with storage - from lstorage.php
$global->takeconfig($storage->request($storage.globalwwwconfig)); // load website config - from lstorage.php
$global->takeconfig($storage->request($storage.auth)); // check if user is logged in - from lauth.php
?>

<html>
<head>
<title><? echo global.websitetitle; ?></title>
</head>
<body>

<?
template->show_header(); // from template.php
template->show_menu();
template->show_body();
template->show_footer();
?>

</body>
</html>

<?
storage->disconnect();
?>
