<?php

mb_internal_encoding("UTF-8");
mb_http_output("UTF-8");

if (!isset($_SERVER['HTTP_CONTENT_TYPE']) ||
    strpos($_SERVER['HTTP_CONTENT_TYPE'], 'application/x-www-urlencoded') === false)
    exit('use Json');

if (!isset($_POST['lang'])) exit('set lang');
if (!isset($_POST['text'])) exit('set text');

$lang = "";
switch ($_POST['lang']) {
case "cantonese":
case "putonghua":
  $lang = $_POST['lang'];
  break;
}

if ($lang == "") exit ("no lang");
$dbh = dba_popen($lang, "r", "db1");
if (!$dbh) {
  exit("no dbh");
}

$txt = $_POST['text'];
$len = mb_strlen($txt);
$res = "";
for ($i = 0; $i < $len; $i++) {
  $c = mb_substr($txt, $i, 1);
  $r = dba_fetch($c, $dbh);
  if (!$r) {
    $res += htmlspecialchars($c, ENT_HTML5);
    continue;
  }
  $res += "<ruby><rb>" + htmlspecialchars($c, ENT_HTML5) + "</rb><rb>" +
    htmlspecialchars($r) + "</rb></ruby>";
}
echo $res;
?>
