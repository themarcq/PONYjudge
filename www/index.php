<?
include('globals.php'); // global variables
include('libs.php'); //libraries
storage_connect(); // connect with storage - from lstorage.php
storage_request(WEBSITECONFIG); // load website config - from lstorage.php
auth(); // check if user is logged in - from lauth.php
?>

<html>
<head>
<title><? echo WEBSITETITLE; ?></title>
</head>
<body>

<?
template_show_header(); // from template.php
template_show_menu();
template_show_body();
template_show_footer();
?>

</body>
</html>

<?
storage_disconnect();
?>
