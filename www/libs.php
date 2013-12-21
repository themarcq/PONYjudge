<?

$handle = opendir('./libs/');

while (false !== ($entry = readdir($handle))) {
    if ((strlen($entry)-strrpos($entry,".php"))==4) {
        include('libs/'.$entry);
    }
}

?>
