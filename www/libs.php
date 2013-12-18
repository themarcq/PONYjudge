<?

if($handle = opendir('./libs/'))echo 'lol';else echo 'nielol';

while (false !== ($entry = readdir($handle))) {
    if ((strlen($entry)-strrpos($entry,".php"))==4) {
        echo "|".'libs/'.$entry."|";include('libs/'.$entry);
    }
}

?>
