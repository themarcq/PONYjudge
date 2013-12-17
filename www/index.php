<?
include('globals.php'); // global variables
$globals= new globals;
$globals->load_config('www.conf');
$globals->take_session();
include('libs.php'); //libraries
$storage=new storage;
$storage->connect($globals); // connect with storage - from lstorage.php
$globals->take_vars($storage->auth());
?>

<html>
<head>
<title><? echo global->website_title; ?></title>
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
