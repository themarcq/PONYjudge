<?

class template {
    public $Errors;
    public $ErrorsNumber=0;
    public $Menus;
    public $RequestedPage;
    public function show() {
        global $GLOBALS;
        echo'
        <html>
        <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8">
        <title>'.$GLOBALS->WebsiteTitle.'</title>
        <link href="'.$GLOBALS->WebsiteUrl.'styles/testing/style.css" rel="stylesheet" type="text/css" />
        </head>
        <body>
        <div id="header"></div>
        <div id="menu">
        ';
        if(count($this->Menus)>0)
        foreach($this->Menus as $title => $url) {
            echo '<div id="menuitem"><a href="'.$url.'">'.$title.'</a></div>';
        }
        echo '  </div>
        <div id="container">
        <div id="innercontainer">
        <h2>PONYJudge - V0.1 ALPHA</h2>
        </div>
        ';
        if(count($this->Errors)>0)
        foreach($this->Errors as $error) {
            echo '<div id="error">'.$error.'</div>';
        }
        include($GLOBALS->WwwDir.'pages/'.$this->RequestedPage.'.php');
        echo'
        </div>
        <div id=footer>PONYJudge www V'.$GLOBALS->WwwVersion.' by '.$GLOBALS->Authors.'</div>
        </body>
        </html
        ';
    }

    public function showError($s) {
        $this->Errors[$this->ErrorsNumber++]=$s;
    }

    public function showMenuItem($title,$url) {
        $this->Menus[$title]=$url;
    }

    public function choose($page) {
        $this->RequestedPage=$page;
    }

}

?>
